{
  extras = hackage:
    {
      packages = {
        "aeson" = (((hackage.aeson)."1.4.6.0").revisions).default;
        "aeson-pretty" = (((hackage.aeson-pretty)."0.8.8").revisions).default;
        "brittany" = (((hackage.brittany)."0.12.1.1").revisions).default;
        "butcher" = (((hackage.butcher)."1.3.2.1").revisions).default;
        "bytestring-trie" = (((hackage.bytestring-trie)."0.2.5.0").revisions).default;
        "cabal-plan" = (((hackage.cabal-plan)."0.5.0.0").revisions).default;
        "constrained-dynamic" = (((hackage.constrained-dynamic)."0.1.0.0").revisions).default;
        "extra" = (((hackage.extra)."1.6.21").revisions).default;
        "floskell" = (((hackage.floskell)."0.10.2").revisions).default;
        "ghc-exactprint" = (((hackage.ghc-exactprint)."0.6.2").revisions).default;
        "ghc-lib-parser" = (((hackage.ghc-lib-parser)."8.8.2.20200205").revisions).default;
        "ghc-lib-parser-ex" = (((hackage.ghc-lib-parser-ex)."8.8.5.3").revisions).default;
        "haddock-api" = (((hackage.haddock-api)."2.22.0").revisions).default;
        "haskell-lsp" = (((hackage.haskell-lsp)."0.20.0.0").revisions).default;
        "haskell-lsp-types" = (((hackage.haskell-lsp-types)."0.20.0.0").revisions).default;
        "haskell-src-exts" = (((hackage.haskell-src-exts)."1.22.0").revisions).default;
        "hie-bios" = (((hackage.hie-bios)."0.4.0").revisions).default;
        "hlint" = (((hackage.hlint)."2.2.11").revisions).default;
        "hoogle" = (((hackage.hoogle)."5.0.17.15").revisions).default;
        "lsp-test" = (((hackage.lsp-test)."0.10.1.0").revisions).default;
        "monad-memo" = (((hackage.monad-memo)."0.4.1").revisions).default;
        "multistate" = (((hackage.multistate)."0.8.0.1").revisions).default;
        "ormolu" = (((hackage.ormolu)."0.0.3.1").revisions).default;
        "parser-combinators" = (((hackage.parser-combinators)."1.2.1").revisions).default;
        "rope-utf16-splay" = (((hackage.rope-utf16-splay)."0.3.1.0").revisions).default;
        "syz" = (((hackage.syz)."0.2.0.0").revisions).default;
        "temporary" = (((hackage.temporary)."1.2.1.1").revisions).default;
        "time-compat" = (((hackage.time-compat)."1.9.2.2").revisions).default;
        "unix-compat" = (((hackage.unix-compat)."0.5.2").revisions).default;
        "unliftio" = (((hackage.unliftio)."0.2.12").revisions).default;
        "unordered-containers" = (((hackage.unordered-containers)."0.2.10.0").revisions).default;
        "yaml" = (((hackage.yaml)."0.11.2.0").revisions).default;
        "unix-time" = (((hackage.unix-time)."0.4.7").revisions).default;
        "hsimport" = (((hackage.hsimport)."0.11.0").revisions)."e8f1774aff97215d7cc3a6c81635fae75b80af182f732f8fe28d1ed6eb9c7401";
        "monad-dijkstra" = (((hackage.monad-dijkstra)."0.1.1.2").revisions).r1;
        haskell-ide-engine = ./haskell-ide-engine.nix;
        hie-plugin-api = ./hie-plugin-api.nix;
        cabal-helper = ./cabal-helper.nix;
        };
      };
  resolver = "lts-13.19";
  modules = [
    ({ lib, ... }:
      {
        packages = {
          "haskell-ide-engine" = {
            flags = { "pedantic" = lib.mkOverride 900 true; };
            };
          "hie-plugin-api" = {
            flags = { "pedantic" = lib.mkOverride 900 true; };
            };
          };
        })
    { packages = {}; }
    ];
  }