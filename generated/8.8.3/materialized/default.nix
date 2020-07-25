{
  extras = hackage:
    {
      packages = {
        "apply-refact" = (((hackage.apply-refact)."0.7.0.0").revisions).default;
        "Cabal" = (((hackage.Cabal)."3.0.2.0").revisions).default;
        "cabal-helper" = (((hackage.cabal-helper)."1.1.0.0").revisions).default;
        "clock" = (((hackage.clock)."0.7.2").revisions).default;
        "constrained-dynamic" = (((hackage.constrained-dynamic)."0.1.0.0").revisions).default;
        "floskell" = (((hackage.floskell)."0.10.2").revisions).default;
        "ghc-lib-parser" = (((hackage.ghc-lib-parser)."8.8.2.20200205").revisions).default;
        "ghc-lib-parser-ex" = (((hackage.ghc-lib-parser-ex)."8.8.5.3").revisions).default;
        "haddock-api" = (((hackage.haddock-api)."2.23.1").revisions).default;
        "hoogle" = (((hackage.hoogle)."5.0.17.15").revisions).default;
        "hsimport" = (((hackage.hsimport)."0.11.0").revisions).default;
        "ilist" = (((hackage.ilist)."0.3.1.0").revisions).default;
        "monad-dijkstra" = (((hackage.monad-dijkstra)."0.1.1.2").revisions).default;
        "semigroups" = (((hackage.semigroups)."0.18.5").revisions).default;
        "temporary" = (((hackage.temporary)."1.2.1.1").revisions).default;
        "unliftio-core" = (((hackage.unliftio-core)."0.2.0.1").revisions).default;
        "hie-bios" = (((hackage.hie-bios)."0.5.0").revisions).default;
        "bytestring-trie" = (((hackage.bytestring-trie)."0.2.5.0").revisions).r1;
        haskell-ide-engine = ./haskell-ide-engine.nix;
        hie-plugin-api = ./hie-plugin-api.nix;
        };
      };
  resolver = "lts-15.10";
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