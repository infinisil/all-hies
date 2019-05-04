#!/usr/bin/env nix-shell
#!nix-shell -i runhaskell shell.nix

{-# LANGUAGE LambdaCase        #-}
{-# LANGUAGE NamedFieldPuns    #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ViewPatterns      #-}

import           Control.Exception          (handleJust)
import           Control.Monad.Reader
import           Data.Aeson                 (decode)
import qualified Data.ByteString.Lazy.Char8 as BS
import           Data.Char                  (isDigit, isHexDigit)
import           Data.List                  (intercalate)
import           Data.Maybe
import           Data.Time
import           Distribution.System        (Arch (..), OS (..), Platform (..))
import           Network.HTTP.Client
import           Network.HTTP.Client.TLS
import           Stack2nix
import           System.Console.Haskeline   hiding (getHistory)
import           System.Directory
import           System.Environment         (setEnv)
import           System.Exit                (ExitCode (..))
import           System.FilePath
import           System.Process
import           Text.Regex.Applicative

data Env = Env
  { cacheDir :: FilePath
  , manager  :: Manager
  }

-- | Initializes the read-only environment
getEnv :: IO Env
getEnv = Env
  <$> getXdgDirectory XdgCache "all-hies"
  <*> newTlsManager

type App = InputT (ReaderT Env IO)

main :: IO ()
main = do
  env <- getEnv
  runReaderT (runInputT haskelineSettings run) env
  where haskelineSettings = defaultSettings { historyFile = Nothing }

run :: App ()
run = do
  updateRepo hie
  updateRepo nixpkgs

  repoPath nixpkgs >>= \path -> liftIO $ setEnv "NIX_PATH" ("nixpkgs=" ++ path)
  setupDirectories

  stable <- latestTag hie
  regenerate stable dirStack2Nix

cfileChannelHistory = "history-nixpkgs-unstable"
cdirPerNixpkgsGhcVersions = "per-nixpkgs/ghcVersions"
cdirPerNixpkgsSha256 = "per-nixpkgs/sha256"
cdirPerHie = "per-hie"
cdirPerGhcMinor = "per-ghcMinor"
dirNixpkgsForGhc = "nixpkgsForGhc"
dirGenerated = "generated"
dirStack2Nix = dirGenerated </> "stack2nix"
dirNixpkgsHashes = dirGenerated </> "nixpkgsHashes"
dirGhcBaseLibraries = dirGenerated </> "ghcBaseLibraries"

setupDirectories :: App ()
setupDirectories = do
  cachePath cdirPerNixpkgsGhcVersions >>= liftIO . createDirectoryIfMissing True
  cachePath cdirPerNixpkgsSha256 >>= liftIO . createDirectoryIfMissing True
  cachePath cdirPerHie >>= liftIO . createDirectoryIfMissing True
  cachePath cdirPerGhcMinor >>= liftIO . createDirectoryIfMissing True
  liftIO $ createDirectoryIfMissing True dirNixpkgsForGhc
  cleanDirectory dirGenerated
  liftIO $ createDirectory dirStack2Nix
  liftIO $ createDirectory dirNixpkgsHashes
  liftIO $ createDirectory dirGhcBaseLibraries

-- | Makes sure that the given directory is existent and empty
cleanDirectory :: FilePath -> App ()
cleanDirectory path = liftIO $ do
  liftIO $ putStrLn $ "Cleaning directory " ++ path
  exists <- doesPathExist path
  when exists $ removeDirectoryRecursive path
  createDirectoryIfMissing True path

-- | Returns the newest tag in the given repository
latestTag :: Repository -> App String
latestTag repo = do
  -- TODO: Use git ls-remote --tags --sort=creatordate --refs instead?
  tags <- lines <$> git repo [ "tag", "--sort", "creatordate" ]
  return $ last tags

-- | Returns the git hash for a specified revision in the given repository
revHash :: Repository -> String -> App String
revHash (Repository url) rev = liftIO $ head . words . head . lines
  <$> readProcess "git" [ "ls-remote", url, rev ] ""

cachePath :: FilePath -> App FilePath
cachePath sub = do
  cache <- lift $ asks cacheDir
  return $ cache </> sub

-- | A call to stack2nix for generating a haskell-ide-engine expression at a specified path, for a specific revision and ghc version
callStack2nix :: String -> FilePath -> Version -> App ()
callStack2nix rev output version = liftIO $ do
  let (Repository repo) = hie
  createDirectoryIfMissing True (takeDirectory output)

  putStrLn $ "Running stack2nix to generate " ++ output ++ " for hie revision " ++ rev ++ " and ghc version " ++ show version

  handleJust (\e -> if e == ExitSuccess then Just () else Nothing) return $
    stack2nix Args
      { argRev = Just rev
      , argOutFile = Just output
      , argStackYaml = "stack-" ++ show version ++ ".yaml"
      , argThreads = 4
      , argTest = False
      , argBench = False
      , argHaddock = False
      , argHackageSnapshot = Nothing
      , argPlatform = Platform X86_64 Linux
      , argUri = repo
      , argIndent = True
      , argVerbose = False
      }

-- | Generate the stack2nix file for the specified HIE git hash and ghc version
genS2N :: String -> Version -> App FilePath
genS2N hash version = do
  path <- cachePath $ cdirPerHie </> hash </> nixVersion version ++ ".nix"
  exists <- liftIO $ doesFileExist path

  nixpkgsRev <- findNixpkgsForGhc version
  sha <- nixpkgsSha nixpkgsRev
  liftIO $ writeFile (dirNixpkgsHashes </> nixpkgsRev) sha

  genBaseLibraries version nixpkgsRev

  unless exists $ do
    liftIO $ putStrLn $ "Using nixpkgs revision " ++ nixpkgsRev ++ " for ghc version " ++ show version
    git nixpkgs [ "checkout", nixpkgsRev ]
    callStack2nix hash path version
  return path

genBaseLibraries :: Version -> String -> App ()
genBaseLibraries version@(Version major minor patch) nixpkgsRev = do
  cache <- cachePath $ cdirPerGhcMinor </> show major ++ show minor
  exists <- liftIO $ doesFileExist cache
  unless exists $ do
    git nixpkgs [ "checkout", nixpkgsRev ]
    ghcPath <- liftIO $ init <$> readProcess "nix-build"
      [ "--no-out-link", "<nixpkgs>", "-A", "haskell.compiler." ++ nixVersion version ] ""
    libs <- liftIO $ readProcess (ghcPath </> "bin/ghc-pkg")
      [ "list", "--no-user-package-db", "--simple" ] ""
    liftIO $ writeFile cache libs
  liftIO $ copyFile cache (dirGhcBaseLibraries </> nixVersion version)

nixpkgsSha :: String -> App String
nixpkgsSha revision = do
  cacheFile <- cachePath $ cdirPerNixpkgsSha256 </> revision
  exists <- liftIO $ doesFileExist cacheFile
  if exists then liftIO $ readFile cacheFile
    else do
    git nixpkgs [ "checkout", revision ]
    path <- repoPath nixpkgs
    tmp <- cachePath "tmp"
    liftIO $ readProcess "cp" ["-rl", path, tmp] ""
    liftIO $ removeDirectoryRecursive (tmp </> ".git")
    hash <- liftIO $ head . lines <$> readProcess "nix-hash" ["--type", "sha256", "--base32", tmp] ""
    liftIO $ writeFile cacheFile hash
    liftIO $ removeDirectoryRecursive tmp
    return hash

-- | Finds a suitable nixpkgs revision that has a the specified compiler available
findNixpkgsForGhc :: Version -> App String
findNixpkgsForGhc version = do
  exists <- liftIO $ doesFileExist path
  if exists then liftIO $ readFile path
  else do
    hist <- getHistory
    revision <- go hist
    liftIO $ writeFile path revision
    return revision

  where
    path :: FilePath
    path = dirNixpkgsForGhc </> nixVersion version

    go :: Hist -> App String
    go [] = fail $ "Couldn't find a nixpkgs for ghc version " ++ show version
    go (h:hist) = do
      versions <- ghcVersionsForNixpkgs h
      if version `elem` versions
      then return h else go hist

-- | Determines the available GHC versions for a nixpkgs revision
ghcVersionsForNixpkgs :: String -> App [Version]
ghcVersionsForNixpkgs rev = do
  path <- cachePath $ cdirPerNixpkgsGhcVersions </> rev
  exists <- liftIO $ doesFileExist path
  if exists then do
    contents <- liftIO $ readFile path
    return $ catMaybes . map (versionRegex `match`) . lines $ contents
    else do
    git nixpkgs [ "checkout", rev ]
    nixpkgs <- repoPath nixpkgs
    stdout <- liftIO $ readProcess "nix-instantiate" [ "--eval", "--json", "-" ]
      ("builtins.attrNames (import " ++ nixpkgs ++ " {}).haskell.compiler")
    case decode (BS.pack stdout) :: Maybe [String] of
      Nothing -> fail $ "Failed to decode nix output: " ++ stdout
      Just versions' -> do
        let versions = catMaybes $ map (nixVersionRegex `match`) versions'
        liftIO $ writeFile path $ unlines $ map show versions
        return versions

-- | Regenerate the specified HIE revision stack2nix files in the given path
regenerate :: String -> FilePath -> App ()
regenerate revision genDir = do
  hash <- revHash hie revision
  liftIO $ putStrLn $ "Writing " ++ revision ++ " to " ++ genDir ++ "/revision"
  liftIO $ writeFile (genDir </> "revision") revision
  git hie [ "checkout", hash ]
  files <- repoPath hie >>= liftIO . listDirectory
  let versions = mapMaybe (stackPathRegex `match`) files
  liftIO $ putStrLn $ "HIE " ++ revision ++ " has ghc versions " ++ intercalate ", " (map show versions)
  forM_ versions $ \version -> do
    file <- genS2N hash version
    liftIO $ copyFile file $ genDir </> nixVersion version ++ ".nix"


newtype Repository = Repository String

nixpkgs :: Repository
nixpkgs = Repository "https://github.com/NixOS/nixpkgs"

hie :: Repository
hie = Repository "https://github.com/haskell/haskell-ide-engine"

-- | Returns the local checkout path to a repository
repoPath :: Repository -> App FilePath
repoPath (Repository (takeFileName -> name)) = lift $ (</> name) <$> asks cacheDir

-- | Runs git with the specified arguments in the given repositories local checkout
git :: Repository -> [String] -> App String
git repo args = do
  path <- repoPath repo
  let allArgs = "-C":path:args
  liftIO $ putStrLn $ "Running git " ++ unwords allArgs
  liftIO $ readProcess "git" allArgs ""

-- | Ensures that the repository repo is cloned to its path with the latest updates fetched
updateRepo :: Repository -> App ()
updateRepo repo@(Repository url@(takeFileName -> name)) = do
  path <- (</> name) <$> lift (asks cacheDir)
  exists <- liftIO $ doesPathExist path
  if exists then do
    git repo [ "clean", "-fd" ]
    git repo [ "reset", "--hard", "HEAD" ]
    git repo [ "fetch", "origin" ]
  else do
    candidate <- (\home -> home </> "src" </> name) <$> liftIO getHomeDirectory
    initial <- (\exists -> if exists then candidate else "")
      <$> liftIO (doesDirectoryExist candidate)
    checkoutPath <- fromMaybe (error "EOF") <$> getInputLineWithInitial
      ("Enter optional path to local " ++ url ++ " checkout for faster cloning: ") (initial, "")

    liftIO $ readProcess "git" (
      [ "clone", url, path, "--recursive" ] ++
      [ arg | not (null checkoutPath), arg <- [ "--reference-if-able", checkoutPath ] ]
      ) ""
  return ()

type Hist = [String]

-- | Returns the nixpkgs-unstable channel commit history recorded by "https://channels.nix.gsc.io" in newest to oldest order
getHistory :: App Hist
getHistory = do
  path <- cachePath cfileChannelHistory
  now <- liftIO getCurrentTime
  useCache <- liftIO (doesFileExist path) >>= \case
    False -> return False
    True -> do
      modTime <- liftIO $ getModificationTime path
      return $ now `diffUTCTime` modTime < 15 * 60
  if useCache then do
    liftIO $ putStrLn $ "Using cached result for " ++ url
    liftIO $ lines <$> readFile path
  else do
    liftIO $ putStrLn $ "Because cache is expired, downloading " ++ url
    mgr <- lift $ asks manager
    response <- liftIO $ responseBody <$> httpLbs (parseRequest_ url) mgr
    -- Because this file is downloaded in the order of oldest to newest
    -- We reverse it for easier processing
    let items = reverse . ("c47ac0d8bf43543d8dcef4895167dd1f7af9d968":) . map (head . BS.words) $ BS.lines response

    liftIO $ BS.writeFile path $ BS.unlines items
    return $ map BS.unpack items
  where
    url = "https://channels.nix.gsc.io/nixpkgs-unstable/history-v2"


-- | A GHC version
data Version = Version Int Int Int
             deriving (Eq, Ord)

instance Show Version where
  show (Version major minor patch) = show major ++ "." ++ show minor ++ "." ++ show patch

-- | Converts a GHC version to the format used for attributes in nixpkgs, such as "ghc864"
nixVersion :: Version -> String
nixVersion (Version major minor patch) = "ghc" ++ show major ++ show minor ++ show patch

-- | Matches a nixpkgs GHC attribute name such as "ghc864" as a version type
nixVersionRegex :: RE Char Version
nixVersionRegex = "ghc" *> (Version <$> digit <*> digit <*> digit)
  where digit = read . (:[]) <$> psym isDigit

-- | Matches a GHC version string such as 8.6.4 to a version type
versionRegex :: RE Char Version
versionRegex = Version
  <$> (int <* sym '.')
  <*> (int <* sym '.')
  <*> int
  where int :: RE Char Int
        int = read <$> many (psym isDigit)

-- | Matches a stack yaml file name such as "stack-8.6.4.yaml" to a GHC version
stackPathRegex :: RE Char Version
stackPathRegex = "stack-" *> versionRegex <* ".yaml"
