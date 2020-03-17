let
  buildDepError = pkg:
    builtins.throw ''
      The Haskell package set does not contain the package: ${pkg} (build dependency).
      
      If you are using Stackage, make sure that you are using a snapshot that contains the package. Otherwise you may need to update the Hackage snapshot you are using, usually by updating haskell.nix.
      '';
  sysDepError = pkg:
    builtins.throw ''
      The Nixpkgs package set does not contain the package: ${pkg} (system dependency).
      
      You may need to augment the system package mapping in haskell.nix so that it can be found.
      '';
  pkgConfDepError = pkg:
    builtins.throw ''
      The pkg-conf packages does not contain the package: ${pkg} (pkg-conf dependency).
      
      You may need to augment the pkg-conf package mapping in haskell.nix so that it can be found.
      '';
  exeDepError = pkg:
    builtins.throw ''
      The local executable components do not include the component: ${pkg} (executable dependency).
      '';
  legacyExeDepError = pkg:
    builtins.throw ''
      The Haskell package set does not contain the package: ${pkg} (executable dependency).
      
      If you are using Stackage, make sure that you are using a snapshot that contains the package. Otherwise you may need to update the Hackage snapshot you are using, usually by updating haskell.nix.
      '';
  buildToolDepError = pkg:
    builtins.throw ''
      Neither the Haskell package set or the Nixpkgs package set contain the package: ${pkg} (build tool dependency).
      
      If this is a system dependency:
      You may need to augment the system package mapping in haskell.nix so that it can be found.
      
      If this is a Haskell dependency:
      If you are using Stackage, make sure that you are using a snapshot that contains the package. Otherwise you may need to update the Hackage snapshot you are using, usually by updating haskell.nix.
      '';
in { system, compiler, flags, pkgs, hsPkgs, pkgconfPkgs, ... }:
  {
    flags = { pedantic = false; };
    package = {
      specVersion = "2.0";
      identifier = { name = "haskell-ide-engine"; version = "1.2"; };
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
      };
    components = {
      "library" = {
        depends = [
          (hsPkgs."Cabal" or (buildDepError "Cabal"))
          (hsPkgs."Diff" or (buildDepError "Diff"))
          (hsPkgs."aeson" or (buildDepError "aeson"))
          (hsPkgs."apply-refact" or (buildDepError "apply-refact"))
          (hsPkgs."async" or (buildDepError "async"))
          (hsPkgs."base" or (buildDepError "base"))
          (hsPkgs."brittany" or (buildDepError "brittany"))
          (hsPkgs."bytestring" or (buildDepError "bytestring"))
          (hsPkgs."Cabal" or (buildDepError "Cabal"))
          (hsPkgs."cabal-helper" or (buildDepError "cabal-helper"))
          (hsPkgs."containers" or (buildDepError "containers"))
          (hsPkgs."data-default" or (buildDepError "data-default"))
          (hsPkgs."directory" or (buildDepError "directory"))
          (hsPkgs."filepath" or (buildDepError "filepath"))
          (hsPkgs."floskell" or (buildDepError "floskell"))
          (hsPkgs."fold-debounce" or (buildDepError "fold-debounce"))
          (hsPkgs."ghc" or (buildDepError "ghc"))
          (hsPkgs."ghc-exactprint" or (buildDepError "ghc-exactprint"))
          (hsPkgs."gitrev" or (buildDepError "gitrev"))
          (hsPkgs."haddock-api" or (buildDepError "haddock-api"))
          (hsPkgs."haddock-library" or (buildDepError "haddock-library"))
          (hsPkgs."haskell-lsp" or (buildDepError "haskell-lsp"))
          (hsPkgs."haskell-lsp-types" or (buildDepError "haskell-lsp-types"))
          (hsPkgs."haskell-src-exts" or (buildDepError "haskell-src-exts"))
          (hsPkgs."hie-plugin-api" or (buildDepError "hie-plugin-api"))
          (hsPkgs."hoogle" or (buildDepError "hoogle"))
          (hsPkgs."hsimport" or (buildDepError "hsimport"))
          (hsPkgs."hslogger" or (buildDepError "hslogger"))
          (hsPkgs."lifted-async" or (buildDepError "lifted-async"))
          (hsPkgs."lens" or (buildDepError "lens"))
          (hsPkgs."monoid-subclasses" or (buildDepError "monoid-subclasses"))
          (hsPkgs."mtl" or (buildDepError "mtl"))
          (hsPkgs."optparse-simple" or (buildDepError "optparse-simple"))
          (hsPkgs."parsec" or (buildDepError "parsec"))
          (hsPkgs."process" or (buildDepError "process"))
          (hsPkgs."safe" or (buildDepError "safe"))
          (hsPkgs."sorted-list" or (buildDepError "sorted-list"))
          (hsPkgs."stm" or (buildDepError "stm"))
          (hsPkgs."syb" or (buildDepError "syb"))
          (hsPkgs."tagsoup" or (buildDepError "tagsoup"))
          (hsPkgs."text" or (buildDepError "text"))
          (hsPkgs."transformers" or (buildDepError "transformers"))
          (hsPkgs."unix-time" or (buildDepError "unix-time"))
          (hsPkgs."unordered-containers" or (buildDepError "unordered-containers"))
          (hsPkgs."vector" or (buildDepError "vector"))
          (hsPkgs."versions" or (buildDepError "versions"))
          (hsPkgs."yaml" or (buildDepError "yaml"))
          (hsPkgs."hie-bios" or (buildDepError "hie-bios"))
          (hsPkgs."bytestring-trie" or (buildDepError "bytestring-trie"))
          (hsPkgs."unliftio" or (buildDepError "unliftio"))
          (hsPkgs."hlint" or (buildDepError "hlint"))
          ] ++ (pkgs.lib).optional (compiler.isGhc && (compiler.version).ge "8.6") (hsPkgs."ormolu" or (buildDepError "ormolu"));
        buildable = true;
        };
      sublibs = {
        "hie-test-utils" = {
          depends = [
            (hsPkgs."base" or (buildDepError "base"))
            (hsPkgs."haskell-ide-engine" or (buildDepError "haskell-ide-engine"))
            (hsPkgs."haskell-lsp" or (buildDepError "haskell-lsp"))
            (hsPkgs."hie-bios" or (buildDepError "hie-bios"))
            (hsPkgs."hie-plugin-api" or (buildDepError "hie-plugin-api"))
            (hsPkgs."aeson" or (buildDepError "aeson"))
            (hsPkgs."blaze-markup" or (buildDepError "blaze-markup"))
            (hsPkgs."containers" or (buildDepError "containers"))
            (hsPkgs."data-default" or (buildDepError "data-default"))
            (hsPkgs."directory" or (buildDepError "directory"))
            (hsPkgs."filepath" or (buildDepError "filepath"))
            (hsPkgs."hslogger" or (buildDepError "hslogger"))
            (hsPkgs."hspec" or (buildDepError "hspec"))
            (hsPkgs."hspec-core" or (buildDepError "hspec-core"))
            (hsPkgs."stm" or (buildDepError "stm"))
            (hsPkgs."text" or (buildDepError "text"))
            (hsPkgs."unordered-containers" or (buildDepError "unordered-containers"))
            (hsPkgs."yaml" or (buildDepError "yaml"))
            ];
          buildable = true;
          };
        };
      exes = {
        "hie" = {
          depends = [
            (hsPkgs."base" or (buildDepError "base"))
            (hsPkgs."containers" or (buildDepError "containers"))
            (hsPkgs."data-default" or (buildDepError "data-default"))
            (hsPkgs."directory" or (buildDepError "directory"))
            (hsPkgs."filepath" or (buildDepError "filepath"))
            (hsPkgs."ghc" or (buildDepError "ghc"))
            (hsPkgs."hie-bios" or (buildDepError "hie-bios"))
            (hsPkgs."haskell-ide-engine" or (buildDepError "haskell-ide-engine"))
            (hsPkgs."haskell-lsp" or (buildDepError "haskell-lsp"))
            (hsPkgs."haskell-lsp-types" or (buildDepError "haskell-lsp-types"))
            (hsPkgs."hie-plugin-api" or (buildDepError "hie-plugin-api"))
            (hsPkgs."hslogger" or (buildDepError "hslogger"))
            (hsPkgs."optparse-simple" or (buildDepError "optparse-simple"))
            (hsPkgs."stm" or (buildDepError "stm"))
            (hsPkgs."text" or (buildDepError "text"))
            (hsPkgs."yaml" or (buildDepError "yaml"))
            ];
          buildable = true;
          };
        "hie-wrapper" = {
          depends = [
            (hsPkgs."base" or (buildDepError "base"))
            (hsPkgs."directory" or (buildDepError "directory"))
            (hsPkgs."filepath" or (buildDepError "filepath"))
            (hsPkgs."hie-bios" or (buildDepError "hie-bios"))
            (hsPkgs."haskell-ide-engine" or (buildDepError "haskell-ide-engine"))
            (hsPkgs."haskell-lsp" or (buildDepError "haskell-lsp"))
            (hsPkgs."hie-plugin-api" or (buildDepError "hie-plugin-api"))
            (hsPkgs."hslogger" or (buildDepError "hslogger"))
            (hsPkgs."optparse-simple" or (buildDepError "optparse-simple"))
            (hsPkgs."process" or (buildDepError "process"))
            ];
          buildable = true;
          };
        };
      tests = {
        "unit-test" = {
          depends = [
            (hsPkgs."QuickCheck" or (buildDepError "QuickCheck"))
            (hsPkgs."aeson" or (buildDepError "aeson"))
            (hsPkgs."cabal-helper" or (buildDepError "cabal-helper"))
            (hsPkgs."ghc" or (buildDepError "ghc"))
            (hsPkgs."base" or (buildDepError "base"))
            (hsPkgs."bytestring" or (buildDepError "bytestring"))
            (hsPkgs."containers" or (buildDepError "containers"))
            (hsPkgs."directory" or (buildDepError "directory"))
            (hsPkgs."filepath" or (buildDepError "filepath"))
            (hsPkgs."free" or (buildDepError "free"))
            (hsPkgs."ghc" or (buildDepError "ghc"))
            (hsPkgs."haskell-ide-engine" or (buildDepError "haskell-ide-engine"))
            (hsPkgs."haskell-lsp-types" or (buildDepError "haskell-lsp-types"))
            (hsPkgs."hie-bios" or (buildDepError "hie-bios"))
            (hsPkgs."hie-test-utils" or (buildDepError "hie-test-utils"))
            (hsPkgs."hie-plugin-api" or (buildDepError "hie-plugin-api"))
            (hsPkgs."hoogle" or (buildDepError "hoogle"))
            (hsPkgs."hspec" or (buildDepError "hspec"))
            (hsPkgs."process" or (buildDepError "process"))
            (hsPkgs."quickcheck-instances" or (buildDepError "quickcheck-instances"))
            (hsPkgs."text" or (buildDepError "text"))
            (hsPkgs."unordered-containers" or (buildDepError "unordered-containers"))
            ];
          build-tools = [
            (hsPkgs.buildPackages.cabal-helper or (pkgs.buildPackages.cabal-helper or (buildToolDepError "cabal-helper")))
            (hsPkgs.buildPackages.hspec-discover or (pkgs.buildPackages.hspec-discover or (buildToolDepError "hspec-discover")))
            ];
          buildable = true;
          };
        "dispatcher-test" = {
          depends = [
            (hsPkgs."base" or (buildDepError "base"))
            (hsPkgs."aeson" or (buildDepError "aeson"))
            (hsPkgs."data-default" or (buildDepError "data-default"))
            (hsPkgs."directory" or (buildDepError "directory"))
            (hsPkgs."filepath" or (buildDepError "filepath"))
            (hsPkgs."ghc" or (buildDepError "ghc"))
            (hsPkgs."haskell-ide-engine" or (buildDepError "haskell-ide-engine"))
            (hsPkgs."haskell-lsp-types" or (buildDepError "haskell-lsp-types"))
            (hsPkgs."hie-test-utils" or (buildDepError "hie-test-utils"))
            (hsPkgs."hie-plugin-api" or (buildDepError "hie-plugin-api"))
            (hsPkgs."hspec" or (buildDepError "hspec"))
            (hsPkgs."stm" or (buildDepError "stm"))
            (hsPkgs."text" or (buildDepError "text"))
            (hsPkgs."unordered-containers" or (buildDepError "unordered-containers"))
            ];
          build-tools = [
            (hsPkgs.buildPackages.hspec-discover or (pkgs.buildPackages.hspec-discover or (buildToolDepError "hspec-discover")))
            ];
          buildable = true;
          };
        "plugin-dispatcher-test" = {
          depends = [
            (hsPkgs."base" or (buildDepError "base"))
            (hsPkgs."data-default" or (buildDepError "data-default"))
            (hsPkgs."directory" or (buildDepError "directory"))
            (hsPkgs."filepath" or (buildDepError "filepath"))
            (hsPkgs."haskell-ide-engine" or (buildDepError "haskell-ide-engine"))
            (hsPkgs."haskell-lsp-types" or (buildDepError "haskell-lsp-types"))
            (hsPkgs."hie-plugin-api" or (buildDepError "hie-plugin-api"))
            (hsPkgs."hie-test-utils" or (buildDepError "hie-test-utils"))
            (hsPkgs."hspec" or (buildDepError "hspec"))
            (hsPkgs."stm" or (buildDepError "stm"))
            (hsPkgs."text" or (buildDepError "text"))
            ];
          buildable = true;
          };
        "func-test" = {
          depends = [
            (hsPkgs."aeson" or (buildDepError "aeson"))
            (hsPkgs."base" or (buildDepError "base"))
            (hsPkgs."data-default" or (buildDepError "data-default"))
            (hsPkgs."directory" or (buildDepError "directory"))
            (hsPkgs."filepath" or (buildDepError "filepath"))
            (hsPkgs."lsp-test" or (buildDepError "lsp-test"))
            (hsPkgs."haskell-ide-engine" or (buildDepError "haskell-ide-engine"))
            (hsPkgs."haskell-lsp-types" or (buildDepError "haskell-lsp-types"))
            (hsPkgs."haskell-lsp" or (buildDepError "haskell-lsp"))
            (hsPkgs."hie-test-utils" or (buildDepError "hie-test-utils"))
            (hsPkgs."hie-plugin-api" or (buildDepError "hie-plugin-api"))
            (hsPkgs."hspec" or (buildDepError "hspec"))
            (hsPkgs."lens" or (buildDepError "lens"))
            (hsPkgs."text" or (buildDepError "text"))
            (hsPkgs."unordered-containers" or (buildDepError "unordered-containers"))
            (hsPkgs."containers" or (buildDepError "containers"))
            ];
          build-tools = [
            (hsPkgs.buildPackages.hspec-discover or (pkgs.buildPackages.hspec-discover or (buildToolDepError "hspec-discover")))
            (hsPkgs.buildPackages.haskell-ide-engine or (pkgs.buildPackages.haskell-ide-engine or (buildToolDepError "haskell-ide-engine")))
            (hsPkgs.buildPackages.cabal-helper or (pkgs.buildPackages.cabal-helper or (buildToolDepError "cabal-helper")))
            ];
          buildable = true;
          };
        "wrapper-test" = {
          depends = [
            (hsPkgs."base" or (buildDepError "base"))
            (hsPkgs."hspec" or (buildDepError "hspec"))
            (hsPkgs."directory" or (buildDepError "directory"))
            (hsPkgs."filepath" or (buildDepError "filepath"))
            (hsPkgs."process" or (buildDepError "process"))
            (hsPkgs."haskell-ide-engine" or (buildDepError "haskell-ide-engine"))
            (hsPkgs."hie-plugin-api" or (buildDepError "hie-plugin-api"))
            ];
          buildable = true;
          };
        };
      };
    } // rec {
    src = (pkgs.lib).mkDefault /nix/store/awqzsvida7b7xp3z38dhkrxc6ldd4f7h-haskell-ide-engine-source-patched/.;
    }