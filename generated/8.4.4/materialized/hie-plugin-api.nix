{ system
  , compiler
  , flags
  , pkgs
  , hsPkgs
  , pkgconfPkgs
  , errorHandler
  , config
  , ... }:
  {
    flags = { pedantic = false; };
    package = {
      specVersion = "2.0";
      identifier = { name = "hie-plugin-api"; version = "1.4"; };
      license = "BSD-3-Clause";
      copyright = "2015 TBD";
      maintainer = "alan.zimm@gmail.com (for now)";
      author = "Many,TBD when we release";
      homepage = "";
      url = "";
      synopsis = "Haskell IDE API for plugin communication";
      description = "Please see README.md";
      buildType = "Simple";
      isLocal = true;
      detailLevel = "FullDetails";
      licenseFiles = [ "LICENSE" ];
      dataDir = "";
      dataFiles = [];
      extraSrcFiles = [];
      extraTmpFiles = [];
      extraDocFiles = [];
      };
    components = {
      "library" = {
        depends = [
          (hsPkgs."base" or (errorHandler.buildDepError "base"))
          (hsPkgs."Diff" or (errorHandler.buildDepError "Diff"))
          (hsPkgs."aeson" or (errorHandler.buildDepError "aeson"))
          (hsPkgs."bytestring-trie" or (errorHandler.buildDepError "bytestring-trie"))
          (hsPkgs."bytestring" or (errorHandler.buildDepError "bytestring"))
          (hsPkgs."cryptohash-sha1" or (errorHandler.buildDepError "cryptohash-sha1"))
          (hsPkgs."constrained-dynamic" or (errorHandler.buildDepError "constrained-dynamic"))
          (hsPkgs."containers" or (errorHandler.buildDepError "containers"))
          (hsPkgs."data-default" or (errorHandler.buildDepError "data-default"))
          (hsPkgs."directory" or (errorHandler.buildDepError "directory"))
          (hsPkgs."filepath" or (errorHandler.buildDepError "filepath"))
          (hsPkgs."fingertree" or (errorHandler.buildDepError "fingertree"))
          (hsPkgs."free" or (errorHandler.buildDepError "free"))
          (hsPkgs."ghc" or (errorHandler.buildDepError "ghc"))
          (hsPkgs."hie-bios" or (errorHandler.buildDepError "hie-bios"))
          (hsPkgs."cabal-helper" or (errorHandler.buildDepError "cabal-helper"))
          (hsPkgs."haskell-lsp" or (errorHandler.buildDepError "haskell-lsp"))
          (hsPkgs."hslogger" or (errorHandler.buildDepError "hslogger"))
          (hsPkgs."unliftio" or (errorHandler.buildDepError "unliftio"))
          (hsPkgs."unliftio-core" or (errorHandler.buildDepError "unliftio-core"))
          (hsPkgs."monad-control" or (errorHandler.buildDepError "monad-control"))
          (hsPkgs."mtl" or (errorHandler.buildDepError "mtl"))
          (hsPkgs."process" or (errorHandler.buildDepError "process"))
          (hsPkgs."sorted-list" or (errorHandler.buildDepError "sorted-list"))
          (hsPkgs."stm" or (errorHandler.buildDepError "stm"))
          (hsPkgs."syb" or (errorHandler.buildDepError "syb"))
          (hsPkgs."text" or (errorHandler.buildDepError "text"))
          (hsPkgs."transformers" or (errorHandler.buildDepError "transformers"))
          (hsPkgs."unordered-containers" or (errorHandler.buildDepError "unordered-containers"))
          (hsPkgs."transformers-base" or (errorHandler.buildDepError "transformers-base"))
          (hsPkgs."yaml" or (errorHandler.buildDepError "yaml"))
          ] ++ (if system.isWindows
          then [ (hsPkgs."Win32" or (errorHandler.buildDepError "Win32")) ]
          else [ (hsPkgs."unix" or (errorHandler.buildDepError "unix")) ]);
        buildable = true;
        modules = [
          "Haskell/Ide/Engine/ArtifactMap"
          "Haskell/Ide/Engine/Compat"
          "Haskell/Ide/Engine/Cradle"
          "Haskell/Ide/Engine/GhcCompat"
          "Haskell/Ide/Engine/GhcUtils"
          "Haskell/Ide/Engine/Config"
          "Haskell/Ide/Engine/Context"
          "Haskell/Ide/Engine/Ghc"
          "Haskell/Ide/Engine/GhcModuleCache"
          "Haskell/Ide/Engine/Logger"
          "Haskell/Ide/Engine/ModuleCache"
          "Haskell/Ide/Engine/MonadFunctions"
          "Haskell/Ide/Engine/MonadTypes"
          "Haskell/Ide/Engine/MultiThreadState"
          "Haskell/Ide/Engine/PluginApi"
          "Haskell/Ide/Engine/PluginUtils"
          "Haskell/Ide/Engine/PluginsIdeMonads"
          "Haskell/Ide/Engine/TypeMap"
          ];
        };
      };
    } // rec {
    src = (pkgs.lib).mkDefault ./hie-plugin-api;
    }