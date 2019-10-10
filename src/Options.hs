module Options
  ( getOptions
  , Options(..)
  ) where

import           Options.Applicative

data Options = Options
  { optName :: String
  , optRev  :: String
  , optRepo :: String
  }

parser :: Parser Options
parser = Options
  <$> strOption
    ( long "name"
   <> short 'n'
   <> metavar "NAME"
   <> help "name of the HIE set to generate as, like stable or unstable"
    )
  <*> strOption
    ( long "revision"
   <> short 'r'
   <> metavar "REV"
   <> help "HIE revision to use, accepts branches, git hashes, tags and more"
    )
  <*> strOption
    ( long "hie-repo"
   <> metavar "URL"
   <> help "Which repository to use"
   <> value "https://github.com/haskell/haskell-ide-engine"
    )

options :: ParserInfo Options
options = info (parser <**> helper)
   ( fullDesc
  <> progDesc "Generate all-hies expressions"
   )

getOptions :: IO Options
getOptions = customExecParser p options where
  p = prefs showHelpOnEmpty
