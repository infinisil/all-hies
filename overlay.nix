let
  sources = import ./sources.nix;
  build = import ./build.nix;
in final: prev: {

  haskell = prev.haskell // {
    packageOverrides = final.lib.composeExtensions prev.haskell.packageOverrides
      (hfinal: hprev: {
        hie = (build {
          glibcName = final.glibc.name;
          inherit sources;
          ghcVersion = hfinal.ghc.version;
        }).combined;
      });
  };

}
# Only include this part if a haskell-nix overlay is there
// prev.lib.optionalAttrs (prev ? haskell-nix) {

  haskell-nix = prev.haskell-nix // {
    custom-tools = prev.haskell-nix.custom-tools // {
      hie.unstable = args: (build {
        glibcName = final.glibc.name;
        inherit sources;
        ghcVersion = args.ghc.version;
      }).combined;
    };
  };

}
