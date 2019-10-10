{-# LANGUAGE NamedFieldPuns    #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ViewPatterns      #-}

import           Control.Exception          (handleJust)
import           Control.Monad.Reader
import           Data.Aeson                 (decode)
import qualified Data.ByteString.Lazy.Char8 as BS
import           Data.Char                  (isDigit, isHexDigit)
import           Data.List                  (intercalate, isPrefixOf)
import           Data.Maybe
import           Data.Time
import           Distribution.System        (Arch (..), OS (..), Platform (..))
import           Network.HTTP.Client
import           Network.HTTP.Client.TLS
import           Stack2nix
import           System.Console.Haskeline   hiding (getHistory)
import           System.Directory
import           System.Environment         (getArgs, setEnv)
import           System.Exit                (ExitCode (..))
import           System.FilePath
import           System.IO                  (hClose)
import           System.IO.Temp
import           System.Process
import           Text.Regex.Applicative

import qualified Cache
import           Options

data Env = Env
  { cacheDir :: FilePath
  , manager  :: Manager
  , opts     :: Options
  }


-- | Initializes the read-only environment
getEnv :: IO Env
getEnv = Env
  <$> getXdgDirectory XdgCache "all-hies"
  <*> newTlsManager
  <*> getOptions

type App = InputT (ReaderT Env IO)

hie :: App Repository
hie = lift $ asks $ Repository . optRepo . opts

main :: IO ()
main = do
  env <- getEnv
  runReaderT (runInputT haskelineSettings run) env
  where haskelineSettings = defaultSettings { historyFile = Nothing }

run :: App ()
run = do
  updateRepo nixpkgs

  repoPath nixpkgs >>= \path -> liftIO $ setEnv "NIX_PATH" ("nixpkgs=" ++ path)

  name <- lift $ asks (optName . opts)
  rev <- lift $ asks (optRev . opts)
  regenerate ("generated" </> name) rev

cleanGenerated :: FilePath -> App ()
cleanGenerated root = do
  cleanDirectory root
  liftIO $ createDirectory (root </> "nixpkgsHashes")
  liftIO $ createDirectory (root </> "ghcBaseLibraries")
  liftIO $ createDirectory (root </> "stack2nix")

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
revHash :: Repository -> String -> App (String, String)
revHash (Repository url) rev = do
  result <- liftIO $ lines <$> readProcess "git" [ "ls-remote", url, rev ] ""
  case result of
    [] -> fail $ "No such revision: " ++ rev
    line:_ -> return (hash, ref) where
      [hash, ref] = words line

-- | A call to stack2nix for generating a haskell-ide-engine expression at a specified path, for a specific revision and ghc version
callStack2nix :: String -> Version -> App BS.ByteString
callStack2nix rev version = do
  Repository repo <- hie

  liftIO $ putStrLn $ "Running stack2nix for hie revision " ++ rev ++ " and ghc version " ++ show version

  liftIO $ withSystemTempFile "all-hies-stack2nix" $ \path handle -> do
    hClose handle
    handleJust (\e -> if e == ExitSuccess then Just () else Nothing) return $
      stack2nix Args
        { argRev = Just rev
        , argOutFile = Just path
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
    BS.readFile path


-- | Generate the stack2nix file for the specified HIE git hash and ghc version
genS2N :: FilePath -> String -> Version -> App BS.ByteString
genS2N root hash version = do

  nixpkgsRev <- findNixpkgsForGhc version
  sha <- nixpkgsSha nixpkgsRev
  liftIO $ writeFile (root </> "nixpkgsHashes" </> nixpkgsRev) sha

  genBaseLibraries root version nixpkgsRev

  Cache.get Cache.ExpiresNever ("per-hie" </> hash </> nixVersion version <.> ".nix") $ do
    liftIO $ putStrLn $ "Using nixpkgs revision " ++ nixpkgsRev ++ " for ghc version " ++ show version
    git nixpkgs [ "checkout", nixpkgsRev ]
    callStack2nix hash version

genBaseLibraries :: FilePath -> Version -> String -> App ()
genBaseLibraries root version@(Version major minor patch) nixpkgsRev = do
  contents <- Cache.get Cache.ExpiresNever ("per-ghcMinor" </> show major ++ show minor) $ do
    git nixpkgs [ "checkout", nixpkgsRev ]
    ghcPath <- liftIO $ init <$> readProcess "nix-build"
      [ "--no-out-link", "<nixpkgs>", "-A", "haskell.compiler." ++ nixVersion version ] ""
    libs <- liftIO $ readProcess (ghcPath </> "bin/ghc-pkg")
      [ "list", "--no-user-package-db", "--simple" ] ""
    return $ BS.pack libs

  liftIO $ BS.writeFile (root </> "ghcBaseLibraries" </> nixVersion version) contents

nixpkgsSha :: String -> App String
nixpkgsSha revision = do
  hash <- Cache.get Cache.ExpiresNever ("per-nixpkgs/sha256" </> revision) $ do
    git nixpkgs [ "checkout", revision ]
    path <- repoPath nixpkgs

    -- tmp needs to be next to nixpkgs itself (same file system), such that hardlinking works, which makes it very efficient
    tmpCache <- lift $ (</> "tmp") <$> asks cacheDir
    liftIO $ createDirectoryIfMissing True tmpCache
    liftIO $ withTempDirectory tmpCache "all-hies-nixpkgs-sha256" $ \tmp -> do
      liftIO $ readProcess "cp" ["-Trl", path, tmp] ""
      liftIO $ removeDirectoryRecursive (tmp </> ".git")
      hash <- liftIO $ head . lines <$> readProcess "nix-hash" ["--type", "sha256", "--base32", tmp] ""
      return $ BS.pack hash

  return $ BS.unpack hash

-- | Finds a suitable nixpkgs revision that has a the specified compiler available
findNixpkgsForGhc :: Version -> App String
findNixpkgsForGhc version = do
  contents <- Cache.getLocal Cache.ExpiresNever ("nixpkgsForGhc" </> nixVersion version) $ do
    hist <- getHistory
    revision <- go hist
    return $ BS.pack revision

  return $ BS.unpack contents

  where
    go :: Hist -> App String
    go [] = fail $ "Couldn't find a nixpkgs for ghc version " ++ show version
    go (h:hist) = do
      versions <- ghcVersionsForNixpkgs h
      if version `elem` versions
      then return h else go hist

-- | Determines the available GHC versions for a nixpkgs revision
ghcVersionsForNixpkgs :: String -> App [Version]
ghcVersionsForNixpkgs rev = do
  contents <- Cache.get Cache.ExpiresNever ("per-nixpkgs/ghcVersions" </> rev) $ do
    git nixpkgs [ "checkout", rev ]
    nixpkgs <- repoPath nixpkgs
    stdout <- liftIO $ readProcess "nix-instantiate" [ "--eval", "--json", "-" ]
      ("builtins.attrNames (import " ++ nixpkgs ++ " {}).haskell.compiler")
    case decode (BS.pack stdout) :: Maybe [String] of
      Nothing -> fail $ "Failed to decode nix output: " ++ stdout
      Just versions' -> do
        let versions = mapMaybe (nixVersionRegex `match`) versions'
        return $ BS.pack $ unlines $ map show versions

  return $ mapMaybe (versionRegex `match`) . lines $ BS.unpack contents

-- | Regenerate the specified HIE revision stack2nix files in the given path
regenerate :: FilePath -> String -> App ()
regenerate root revision = do
  liftIO $ putStrLn $ "Regenerating " ++ root ++ " with revision " ++ revision
  cleanGenerated root
  hieRepo <- hie
  (hash, ref) <- revHash hieRepo revision
  let revName = if "refs/heads/" `isPrefixOf` ref
        then take 10 hash else revision
  liftIO $ putStrLn $ "Regenerating for revision " ++ revName ++ " (" ++ hash ++ ")"
  liftIO $ putStrLn $ "Writing " ++ revName ++ " to " ++ root ++ "stack2nix/revision"
  liftIO $ writeFile (root </> "stack2nix/revision") revName
  files <- listRepoFiles hieRepo
  let versions = mapMaybe (stackPathRegex `match`) files
  liftIO $ putStrLn $ "HIE " ++ revName ++ " has ghc versions " ++ intercalate ", " (map show versions)
  forM_ versions $ \version -> do
    contents <- genS2N root hash version
    liftIO $ BS.writeFile (root </> "stack2nix" </> nixVersion version <.> "nix") contents

listRepoFiles :: Repository -> App [FilePath]
listRepoFiles (Repository repo) = liftIO $ withSystemTempDirectory "all-hies-repo" $ \tmpDir -> do
  readProcess "git" [ "clone", repo, tmpDir ] ""
  listDirectory tmpDir

newtype Repository = Repository String

nixpkgs :: Repository
nixpkgs = Repository "https://github.com/NixOS/nixpkgs"

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
  path <- repoPath repo
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
  contents <- Cache.get (Cache.ExpiresAfter (15 * 60)) "history-nixpkgs-unstable" $ do
    mgr <- lift $ asks manager
    response <- liftIO $ responseBody <$> httpLbs (parseRequest_ url) mgr
    let items = reverse . ("c47ac0d8bf43543d8dcef4895167dd1f7af9d968":) . map (head . BS.words) $ BS.lines response
    return $ BS.unlines items

  return $ map BS.unpack . BS.lines $ contents
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
