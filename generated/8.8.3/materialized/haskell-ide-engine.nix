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
      identifier = { name = "haskell-ide-engine"; version = "1.4"; };
      license = "BSD-3-Clause";
      copyright = "2015 - 2019, TBD";
      maintainer = "alan.zimm@gmail.com (for now)";
      author = "Many, TBD when we release";
      homepage = "http://github.com/githubuser/haskell-ide-engine#readme";
      url = "";
      synopsis = "Provide a common engine to power any Haskell IDE";
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
          (hsPkgs."Cabal" or (errorHandler.buildDepError "Cabal"))
          (hsPkgs."Diff" or (errorHandler.buildDepError "Diff"))
          (hsPkgs."aeson" or (errorHandler.buildDepError "aeson"))
          (hsPkgs."apply-refact" or (errorHandler.buildDepError "apply-refact"))
          (hsPkgs."async" or (errorHandler.buildDepError "async"))
          (hsPkgs."base" or (errorHandler.buildDepError "base"))
          (hsPkgs."brittany" or (errorHandler.buildDepError "brittany"))
          (hsPkgs."bytestring" or (errorHandler.buildDepError "bytestring"))
          (hsPkgs."Cabal" or (errorHandler.buildDepError "Cabal"))
          (hsPkgs."cabal-helper" or (errorHandler.buildDepError "cabal-helper"))
          (hsPkgs."containers" or (errorHandler.buildDepError "containers"))
          (hsPkgs."data-default" or (errorHandler.buildDepError "data-default"))
          (hsPkgs."directory" or (errorHandler.buildDepError "directory"))
          (hsPkgs."filepath" or (errorHandler.buildDepError "filepath"))
          (hsPkgs."floskell" or (errorHandler.buildDepError "floskell"))
          (hsPkgs."fold-debounce" or (errorHandler.buildDepError "fold-debounce"))
          (hsPkgs."ghc" or (errorHandler.buildDepError "ghc"))
          (hsPkgs."ghc-exactprint" or (errorHandler.buildDepError "ghc-exactprint"))
          (hsPkgs."gitrev" or (errorHandler.buildDepError "gitrev"))
          (hsPkgs."haddock-api" or (errorHandler.buildDepError "haddock-api"))
          (hsPkgs."haddock-library" or (errorHandler.buildDepError "haddock-library"))
          (hsPkgs."haskell-lsp" or (errorHandler.buildDepError "haskell-lsp"))
          (hsPkgs."haskell-lsp-types" or (errorHandler.buildDepError "haskell-lsp-types"))
          (hsPkgs."haskell-src-exts" or (errorHandler.buildDepError "haskell-src-exts"))
          (hsPkgs."hie-plugin-api" or (errorHandler.buildDepError "hie-plugin-api"))
          (hsPkgs."hoogle" or (errorHandler.buildDepError "hoogle"))
          (hsPkgs."hsimport" or (errorHandler.buildDepError "hsimport"))
          (hsPkgs."hslogger" or (errorHandler.buildDepError "hslogger"))
          (hsPkgs."lifted-async" or (errorHandler.buildDepError "lifted-async"))
          (hsPkgs."lens" or (errorHandler.buildDepError "lens"))
          (hsPkgs."monoid-subclasses" or (errorHandler.buildDepError "monoid-subclasses"))
          (hsPkgs."mtl" or (errorHandler.buildDepError "mtl"))
          (hsPkgs."optparse-simple" or (errorHandler.buildDepError "optparse-simple"))
          (hsPkgs."parsec" or (errorHandler.buildDepError "parsec"))
          (hsPkgs."process" or (errorHandler.buildDepError "process"))
          (hsPkgs."safe" or (errorHandler.buildDepError "safe"))
          (hsPkgs."sorted-list" or (errorHandler.buildDepError "sorted-list"))
          (hsPkgs."stm" or (errorHandler.buildDepError "stm"))
          (hsPkgs."syb" or (errorHandler.buildDepError "syb"))
          (hsPkgs."tagsoup" or (errorHandler.buildDepError "tagsoup"))
          (hsPkgs."text" or (errorHandler.buildDepError "text"))
          (hsPkgs."transformers" or (errorHandler.buildDepError "transformers"))
          (hsPkgs."unix-time" or (errorHandler.buildDepError "unix-time"))
          (hsPkgs."unordered-containers" or (errorHandler.buildDepError "unordered-containers"))
          (hsPkgs."vector" or (errorHandler.buildDepError "vector"))
          (hsPkgs."versions" or (errorHandler.buildDepError "versions"))
          (hsPkgs."yaml" or (errorHandler.buildDepError "yaml"))
          (hsPkgs."hie-bios" or (errorHandler.buildDepError "hie-bios"))
          (hsPkgs."bytestring-trie" or (errorHandler.buildDepError "bytestring-trie"))
          (hsPkgs."unliftio" or (errorHandler.buildDepError "unliftio"))
          (hsPkgs."hlint" or (errorHandler.buildDepError "hlint"))
          ] ++ (pkgs.lib).optional (compiler.isGhc && (compiler.version).ge "8.6") (hsPkgs."ormolu" or (errorHandler.buildDepError "ormolu"));
        buildable = true;
        modules = [
          "Paths_haskell_ide_engine"
          "Haskell/Ide/Engine/Channel"
          "Haskell/Ide/Engine/CodeActions"
          "Haskell/Ide/Engine/Completions"
          "Haskell/Ide/Engine/Reactor"
          "Haskell/Ide/Engine/Options"
          "Haskell/Ide/Engine/Plugin/ApplyRefact"
          "Haskell/Ide/Engine/Plugin/Brittany"
          "Haskell/Ide/Engine/Plugin/Example2"
          "Haskell/Ide/Engine/Plugin/Floskell"
          "Haskell/Ide/Engine/Plugin/Haddock"
          "Haskell/Ide/Engine/Plugin/HfaAlign"
          "Haskell/Ide/Engine/Plugin/HsImport"
          "Haskell/Ide/Engine/Plugin/Liquid"
          "Haskell/Ide/Engine/Plugin/Ormolu"
          "Haskell/Ide/Engine/Plugin/Package"
          "Haskell/Ide/Engine/Plugin/Package/Compat"
          "Haskell/Ide/Engine/Plugin/Pragmas"
          "Haskell/Ide/Engine/Plugin/Generic"
          "Haskell/Ide/Engine/Plugin/GhcMod"
          "Haskell/Ide/Engine/Scheduler"
          "Haskell/Ide/Engine/Support/FromHaRe"
          "Haskell/Ide/Engine/Support/Hoogle"
          "Haskell/Ide/Engine/Support/Fuzzy"
          "Haskell/Ide/Engine/Support/HieExtras"
          "Haskell/Ide/Engine/Server"
          "Haskell/Ide/Engine/Types"
          "Haskell/Ide/Engine/Version"
          ];
        hsSourceDirs = [ "src" ];
        };
      sublibs = {
        "hie-test-utils" = {
          depends = [
            (hsPkgs."base" or (errorHandler.buildDepError "base"))
            (hsPkgs."haskell-ide-engine" or (errorHandler.buildDepError "haskell-ide-engine"))
            (hsPkgs."haskell-lsp" or (errorHandler.buildDepError "haskell-lsp"))
            (hsPkgs."hie-bios" or (errorHandler.buildDepError "hie-bios"))
            (hsPkgs."hie-plugin-api" or (errorHandler.buildDepError "hie-plugin-api"))
            (hsPkgs."aeson" or (errorHandler.buildDepError "aeson"))
            (hsPkgs."blaze-markup" or (errorHandler.buildDepError "blaze-markup"))
            (hsPkgs."containers" or (errorHandler.buildDepError "containers"))
            (hsPkgs."data-default" or (errorHandler.buildDepError "data-default"))
            (hsPkgs."directory" or (errorHandler.buildDepError "directory"))
            (hsPkgs."filepath" or (errorHandler.buildDepError "filepath"))
            (hsPkgs."hslogger" or (errorHandler.buildDepError "hslogger"))
            (hsPkgs."hspec" or (errorHandler.buildDepError "hspec"))
            (hsPkgs."hspec-core" or (errorHandler.buildDepError "hspec-core"))
            (hsPkgs."stm" or (errorHandler.buildDepError "stm"))
            (hsPkgs."text" or (errorHandler.buildDepError "text"))
            (hsPkgs."unordered-containers" or (errorHandler.buildDepError "unordered-containers"))
            (hsPkgs."yaml" or (errorHandler.buildDepError "yaml"))
            ];
          buildable = true;
          modules = [ "TestUtils" ];
          hsSourceDirs = [ "test/utils" ];
          };
        };
      exes = {
        "hie" = {
          depends = [
            (hsPkgs."base" or (errorHandler.buildDepError "base"))
            (hsPkgs."containers" or (errorHandler.buildDepError "containers"))
            (hsPkgs."data-default" or (errorHandler.buildDepError "data-default"))
            (hsPkgs."directory" or (errorHandler.buildDepError "directory"))
            (hsPkgs."filepath" or (errorHandler.buildDepError "filepath"))
            (hsPkgs."ghc" or (errorHandler.buildDepError "ghc"))
            (hsPkgs."hie-bios" or (errorHandler.buildDepError "hie-bios"))
            (hsPkgs."haskell-ide-engine" or (errorHandler.buildDepError "haskell-ide-engine"))
            (hsPkgs."haskell-lsp" or (errorHandler.buildDepError "haskell-lsp"))
            (hsPkgs."haskell-lsp-types" or (errorHandler.buildDepError "haskell-lsp-types"))
            (hsPkgs."hie-plugin-api" or (errorHandler.buildDepError "hie-plugin-api"))
            (hsPkgs."hslogger" or (errorHandler.buildDepError "hslogger"))
            (hsPkgs."optparse-simple" or (errorHandler.buildDepError "optparse-simple"))
            (hsPkgs."stm" or (errorHandler.buildDepError "stm"))
            (hsPkgs."text" or (errorHandler.buildDepError "text"))
            (hsPkgs."yaml" or (errorHandler.buildDepError "yaml"))
            ];
          buildable = true;
          modules = [ "Paths_haskell_ide_engine" "RunTest" ];
          hsSourceDirs = [ "app" ];
          mainPath = [
            "MainHie.hs"
            ] ++ (pkgs.lib).optional (flags.pedantic) "";
          };
        "hie-wrapper" = {
          depends = [
            (hsPkgs."base" or (errorHandler.buildDepError "base"))
            (hsPkgs."directory" or (errorHandler.buildDepError "directory"))
            (hsPkgs."filepath" or (errorHandler.buildDepError "filepath"))
            (hsPkgs."hie-bios" or (errorHandler.buildDepError "hie-bios"))
            (hsPkgs."haskell-ide-engine" or (errorHandler.buildDepError "haskell-ide-engine"))
            (hsPkgs."haskell-lsp" or (errorHandler.buildDepError "haskell-lsp"))
            (hsPkgs."hie-plugin-api" or (errorHandler.buildDepError "hie-plugin-api"))
            (hsPkgs."hslogger" or (errorHandler.buildDepError "hslogger"))
            (hsPkgs."optparse-simple" or (errorHandler.buildDepError "optparse-simple"))
            (hsPkgs."process" or (errorHandler.buildDepError "process"))
            ];
          buildable = true;
          modules = [ "Paths_haskell_ide_engine" ];
          hsSourceDirs = [ "app" ];
          mainPath = [
            "HieWrapper.hs"
            ] ++ (pkgs.lib).optional (flags.pedantic) "";
          };
        };
      tests = {
        "unit-test" = {
          depends = [
            (hsPkgs."QuickCheck" or (errorHandler.buildDepError "QuickCheck"))
            (hsPkgs."aeson" or (errorHandler.buildDepError "aeson"))
            (hsPkgs."cabal-helper" or (errorHandler.buildDepError "cabal-helper"))
            (hsPkgs."ghc" or (errorHandler.buildDepError "ghc"))
            (hsPkgs."base" or (errorHandler.buildDepError "base"))
            (hsPkgs."bytestring" or (errorHandler.buildDepError "bytestring"))
            (hsPkgs."containers" or (errorHandler.buildDepError "containers"))
            (hsPkgs."directory" or (errorHandler.buildDepError "directory"))
            (hsPkgs."filepath" or (errorHandler.buildDepError "filepath"))
            (hsPkgs."free" or (errorHandler.buildDepError "free"))
            (hsPkgs."ghc" or (errorHandler.buildDepError "ghc"))
            (hsPkgs."haskell-ide-engine" or (errorHandler.buildDepError "haskell-ide-engine"))
            (hsPkgs."haskell-lsp-types" or (errorHandler.buildDepError "haskell-lsp-types"))
            (hsPkgs."hie-bios" or (errorHandler.buildDepError "hie-bios"))
            (hsPkgs."hie-test-utils" or (errorHandler.buildDepError "hie-test-utils"))
            (hsPkgs."hie-plugin-api" or (errorHandler.buildDepError "hie-plugin-api"))
            (hsPkgs."hoogle" or (errorHandler.buildDepError "hoogle"))
            (hsPkgs."hspec" or (errorHandler.buildDepError "hspec"))
            (hsPkgs."optparse-applicative" or (errorHandler.buildDepError "optparse-applicative"))
            (hsPkgs."process" or (errorHandler.buildDepError "process"))
            (hsPkgs."quickcheck-instances" or (errorHandler.buildDepError "quickcheck-instances"))
            (hsPkgs."text" or (errorHandler.buildDepError "text"))
            (hsPkgs."unordered-containers" or (errorHandler.buildDepError "unordered-containers"))
            ];
          build-tools = [
            (hsPkgs.buildPackages.cabal-helper or (pkgs.buildPackages.cabal-helper or (errorHandler.buildToolDepError "cabal-helper")))
            (hsPkgs.buildPackages.hspec-discover or (pkgs.buildPackages.hspec-discover or (errorHandler.buildToolDepError "hspec-discover")))
            ];
          buildable = true;
          modules = [
            "ApplyRefactPluginSpec"
            "CabalHelperSpec"
            "CodeActionsSpec"
            "ContextSpec"
            "DiffSpec"
            "ExtensibleStateSpec"
            "GenericPluginSpec"
            "GhcModPluginSpec"
            "HooglePluginSpec"
            "HsImportSpec"
            "JsonSpec"
            "LiquidSpec"
            "OptionsSpec"
            "PackagePluginSpec"
            "Paths_haskell_ide_engine"
            "Spec"
            ];
          hsSourceDirs = [ "test/unit" ];
          mainPath = [ "Main.hs" ];
          };
        "dispatcher-test" = {
          depends = [
            (hsPkgs."base" or (errorHandler.buildDepError "base"))
            (hsPkgs."aeson" or (errorHandler.buildDepError "aeson"))
            (hsPkgs."data-default" or (errorHandler.buildDepError "data-default"))
            (hsPkgs."directory" or (errorHandler.buildDepError "directory"))
            (hsPkgs."filepath" or (errorHandler.buildDepError "filepath"))
            (hsPkgs."ghc" or (errorHandler.buildDepError "ghc"))
            (hsPkgs."haskell-ide-engine" or (errorHandler.buildDepError "haskell-ide-engine"))
            (hsPkgs."haskell-lsp-types" or (errorHandler.buildDepError "haskell-lsp-types"))
            (hsPkgs."hie-test-utils" or (errorHandler.buildDepError "hie-test-utils"))
            (hsPkgs."hie-plugin-api" or (errorHandler.buildDepError "hie-plugin-api"))
            (hsPkgs."hspec" or (errorHandler.buildDepError "hspec"))
            (hsPkgs."stm" or (errorHandler.buildDepError "stm"))
            (hsPkgs."text" or (errorHandler.buildDepError "text"))
            (hsPkgs."unordered-containers" or (errorHandler.buildDepError "unordered-containers"))
            ];
          build-tools = [
            (hsPkgs.buildPackages.hspec-discover or (pkgs.buildPackages.hspec-discover or (errorHandler.buildToolDepError "hspec-discover")))
            ];
          buildable = true;
          hsSourceDirs = [ "test/dispatcher" ];
          mainPath = [ "Main.hs" ];
          };
        "plugin-dispatcher-test" = {
          depends = [
            (hsPkgs."base" or (errorHandler.buildDepError "base"))
            (hsPkgs."data-default" or (errorHandler.buildDepError "data-default"))
            (hsPkgs."directory" or (errorHandler.buildDepError "directory"))
            (hsPkgs."filepath" or (errorHandler.buildDepError "filepath"))
            (hsPkgs."haskell-ide-engine" or (errorHandler.buildDepError "haskell-ide-engine"))
            (hsPkgs."haskell-lsp-types" or (errorHandler.buildDepError "haskell-lsp-types"))
            (hsPkgs."hie-plugin-api" or (errorHandler.buildDepError "hie-plugin-api"))
            (hsPkgs."hie-test-utils" or (errorHandler.buildDepError "hie-test-utils"))
            (hsPkgs."hspec" or (errorHandler.buildDepError "hspec"))
            (hsPkgs."stm" or (errorHandler.buildDepError "stm"))
            (hsPkgs."text" or (errorHandler.buildDepError "text"))
            ];
          buildable = true;
          hsSourceDirs = [ "test/plugin-dispatcher" ];
          mainPath = [ "Main.hs" ];
          };
        "func-test" = {
          depends = [
            (hsPkgs."aeson" or (errorHandler.buildDepError "aeson"))
            (hsPkgs."base" or (errorHandler.buildDepError "base"))
            (hsPkgs."data-default" or (errorHandler.buildDepError "data-default"))
            (hsPkgs."directory" or (errorHandler.buildDepError "directory"))
            (hsPkgs."filepath" or (errorHandler.buildDepError "filepath"))
            (hsPkgs."lsp-test" or (errorHandler.buildDepError "lsp-test"))
            (hsPkgs."haskell-ide-engine" or (errorHandler.buildDepError "haskell-ide-engine"))
            (hsPkgs."haskell-lsp-types" or (errorHandler.buildDepError "haskell-lsp-types"))
            (hsPkgs."haskell-lsp" or (errorHandler.buildDepError "haskell-lsp"))
            (hsPkgs."hie-test-utils" or (errorHandler.buildDepError "hie-test-utils"))
            (hsPkgs."hie-plugin-api" or (errorHandler.buildDepError "hie-plugin-api"))
            (hsPkgs."hspec" or (errorHandler.buildDepError "hspec"))
            (hsPkgs."lens" or (errorHandler.buildDepError "lens"))
            (hsPkgs."text" or (errorHandler.buildDepError "text"))
            (hsPkgs."unordered-containers" or (errorHandler.buildDepError "unordered-containers"))
            (hsPkgs."containers" or (errorHandler.buildDepError "containers"))
            ];
          build-tools = [
            (hsPkgs.buildPackages.hspec-discover or (pkgs.buildPackages.hspec-discover or (errorHandler.buildToolDepError "hspec-discover")))
            (hsPkgs.buildPackages.haskell-ide-engine or (pkgs.buildPackages.haskell-ide-engine or (errorHandler.buildToolDepError "haskell-ide-engine")))
            (hsPkgs.buildPackages.cabal-helper or (pkgs.buildPackages.cabal-helper or (errorHandler.buildToolDepError "cabal-helper")))
            ];
          buildable = true;
          modules = [
            "CompletionSpec"
            "CommandSpec"
            "DeferredSpec"
            "DefinitionSpec"
            "DiagnosticsSpec"
            "FormatSpec"
            "FunctionalBadProjectSpec"
            "FunctionalCodeActionsSpec"
            "FunctionalLiquidSpec"
            "FunctionalSpec"
            "HieBiosSpec"
            "HighlightSpec"
            "HoverSpec"
            "ProgressSpec"
            "ReferencesSpec"
            "RenameSpec"
            "SymbolsSpec"
            "TypeDefinitionSpec"
            "Utils"
            ];
          hsSourceDirs = [ "test/functional" ];
          mainPath = [ "Main.hs" ];
          };
        "wrapper-test" = {
          depends = [
            (hsPkgs."base" or (errorHandler.buildDepError "base"))
            (hsPkgs."hspec" or (errorHandler.buildDepError "hspec"))
            (hsPkgs."directory" or (errorHandler.buildDepError "directory"))
            (hsPkgs."filepath" or (errorHandler.buildDepError "filepath"))
            (hsPkgs."process" or (errorHandler.buildDepError "process"))
            (hsPkgs."haskell-ide-engine" or (errorHandler.buildDepError "haskell-ide-engine"))
            (hsPkgs."hie-plugin-api" or (errorHandler.buildDepError "hie-plugin-api"))
            ];
          buildable = true;
          hsSourceDirs = [ "test/wrapper" ];
          mainPath = [ "HieWrapper.hs" ];
          };
        };
      };
    } // rec {
    src = (pkgs.lib).mkDefault ./.;
    }