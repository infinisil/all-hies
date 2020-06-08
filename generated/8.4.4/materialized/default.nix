{
  extras = hackage:
    {
      packages = {
        "aeson" = (((hackage.aeson)."1.4.6.0").revisions).default;
        "aeson-pretty" = (((hackage.aeson-pretty)."0.8.8").revisions).default;
        "base-orphans" = (((hackage.base-orphans)."0.8.2").revisions).default;
        "bifunctors" = (((hackage.bifunctors)."5.5.6").revisions).default;
        "brittany" = (((hackage.brittany)."0.12.1.1").revisions).default;
        "bytestring-trie" = (((hackage.bytestring-trie)."0.2.5.0").revisions).default;
        "Cabal" = (((hackage.Cabal)."3.0.2.0").revisions).default;
        "cabal-doctest" = (((hackage.cabal-doctest)."1.0.8").revisions).default;
        "cabal-helper" = (((hackage.cabal-helper)."1.1.0.0").revisions).default;
        "cabal-plan" = (((hackage.cabal-plan)."0.5.0.0").revisions).default;
        "connection" = (((hackage.connection)."0.3.1").revisions).default;
        "constrained-dynamic" = (((hackage.constrained-dynamic)."0.1.0.0").revisions).default;
        "extra" = (((hackage.extra)."1.6.21").revisions).default;
        "file-embed" = (((hackage.file-embed)."0.0.11").revisions).default;
        "filepattern" = (((hackage.filepattern)."0.1.1").revisions).default;
        "floskell" = (((hackage.floskell)."0.10.2").revisions).default;
        "generic-deriving" = (((hackage.generic-deriving)."1.13.1").revisions).default;
        "ghc-exactprint" = (((hackage.ghc-exactprint)."0.6.2").revisions).default;
        "ghc-lib-parser" = (((hackage.ghc-lib-parser)."8.8.2.20200205").revisions).default;
        "ghc-lib-parser-ex" = (((hackage.ghc-lib-parser-ex)."8.8.5.3").revisions).default;
        "ghc-paths" = (((hackage.ghc-paths)."0.1.0.12").revisions).default;
        "haddock-library" = (((hackage.haddock-library)."1.6.0").revisions).default;
        "happy" = (((hackage.happy)."1.19.12").revisions).default;
        "haskell-lsp" = (((hackage.haskell-lsp)."0.20.0.0").revisions).default;
        "haskell-lsp-types" = (((hackage.haskell-lsp-types)."0.20.0.0").revisions).default;
        "haskell-src-exts" = (((hackage.haskell-src-exts)."1.22.0").revisions).default;
        "haskell-src-exts-util" = (((hackage.haskell-src-exts-util)."0.2.5").revisions).default;
        "hie-bios" = (((hackage.hie-bios)."0.5.0").revisions).default;
        "hlint" = (((hackage.hlint)."2.2.11").revisions).default;
        "hoogle" = (((hackage.hoogle)."5.0.17.15").revisions).default;
        "hslogger" = (((hackage.hslogger)."1.3.1.0").revisions).default;
        "invariant" = (((hackage.invariant)."0.5.3").revisions).default;
        "lens" = (((hackage.lens)."4.18.1").revisions).default;
        "libyaml" = (((hackage.libyaml)."0.1.1.0").revisions).default;
        "lsp-test" = (((hackage.lsp-test)."0.10.1.0").revisions).default;
        "microlens-th" = (((hackage.microlens-th)."0.4.3.2").revisions).default;
        "monad-dijkstra" = (((hackage.monad-dijkstra)."0.1.1.2").revisions).default;
        "network" = (((hackage.network)."3.1.1.1").revisions).default;
        "network-bsd" = (((hackage.network-bsd)."2.8.1.0").revisions).default;
        "optparse-simple" = (((hackage.optparse-simple)."0.1.0").revisions).default;
        "parser-combinators" = (((hackage.parser-combinators)."1.2.1").revisions).default;
        "pretty-show" = (((hackage.pretty-show)."1.9.5").revisions).default;
        "profunctors" = (((hackage.profunctors)."5.5.1").revisions).default;
        "resourcet" = (((hackage.resourcet)."1.2.3").revisions).default;
        "rope-utf16-splay" = (((hackage.rope-utf16-splay)."0.3.1.0").revisions).default;
        "simple-sendfile" = (((hackage.simple-sendfile)."0.2.30").revisions).default;
        "socks" = (((hackage.socks)."0.6.1").revisions).default;
        "syz" = (((hackage.syz)."0.2.0.0").revisions).default;
        "unix-compat" = (((hackage.unix-compat)."0.5.2").revisions).default;
        "unliftio" = (((hackage.unliftio)."0.2.12.1").revisions).default;
        "unliftio-core" = (((hackage.unliftio-core)."0.2.0.1").revisions).default;
        "unordered-containers" = (((hackage.unordered-containers)."0.2.10.0").revisions).default;
        "yaml" = (((hackage.yaml)."0.11.2.0").revisions).default;
        "th-abstraction" = (((hackage.th-abstraction)."0.3.1.0").revisions).default;
        "type-equality" = (((hackage.type-equality)."1").revisions).default;
        "unix-time" = (((hackage.unix-time)."0.4.7").revisions).default;
        "temporary" = (((hackage.temporary)."1.2.1.1").revisions).default;
        "time-compat" = (((hackage.time-compat)."1.9.2.2").revisions).default;
        "time-manager" = (((hackage.time-manager)."0.0.0").revisions).default;
        "warp" = (((hackage.warp)."3.2.28").revisions).default;
        "wai" = (((hackage.wai)."3.2.2.1").revisions).default;
        "haddock-api" = (((hackage.haddock-api)."2.20.0").revisions).r1;
        "hsimport" = (((hackage.hsimport)."0.11.0").revisions).r2;
        haskell-ide-engine = ./haskell-ide-engine.nix;
        hie-plugin-api = ./hie-plugin-api.nix;
        };
      };
  resolver = "lts-12.26";
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