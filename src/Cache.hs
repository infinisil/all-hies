module Cache
  ( get
  , getLocal
  , Expires(..)
  , Key
  , Value
  ) where

import           Control.Monad.IO.Class
import qualified Data.ByteString.Lazy.Char8 as BS
import           Data.Time
import           System.Directory
import           System.FilePath

type Key = FilePath
type Value = BS.ByteString

data Expires = ExpiresNever
             | ExpiresAfter NominalDiffTime

get :: MonadIO m => Expires -> Key -> m Value -> m Value
get expires key generator = do
  path <- liftIO $ (</> key) <$> getXdgDirectory XdgCache "all-hies"
  getWithBase expires path generator

getLocal :: MonadIO m => Expires -> Key -> m Value -> m Value
getLocal expires key generator = do
  path <- liftIO $ (</> key) <$> getCurrentDirectory
  getWithBase expires path generator

getWithBase :: MonadIO m => Expires -> FilePath -> m Value -> m Value
getWithBase expires path generator = do
  exists <- liftIO $ doesFileExist path
  needsRefresh <- if exists then case expires of
    ExpiresNever -> return False
    ExpiresAfter seconds -> do
      now <- liftIO getCurrentTime
      modTime <- liftIO $ getModificationTime path
      return $ now `diffUTCTime` modTime > seconds
    else return True
  if needsRefresh then do
    contents <- generator
    liftIO $ createDirectoryIfMissing True (takeDirectory path)
    liftIO $ BS.writeFile path contents
    return contents
    else liftIO $ BS.readFile path
