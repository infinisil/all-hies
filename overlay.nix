let
  sources = import ./sources.nix;
  build = import ./build.nix;
in final: prev: {

  haskell = prev.haskell // {
    packageOverrides = final.lib.composeExtensions prev.haskell.packageOverrides
      (hfinal: hprev: {
        hie = (build {
          pinned = true;
          glibcName = final.glibc.name;
          inherit sources;
          ghcVersion = hfinal.ghc.version;
        }).combined;
      });
  };

} // prev.lib.optionalAttrs (prev ? haskell-nix) {

  haskell-nix = prev.haskell-nix // {
    custom-tools = prev.haskell-nix.custom-tools // {
      hie.unstable = args: (build {
        pinned = args.pinned or true;
        glibcName = final.glibc.name;
        pkgs = final;
        inherit sources;
        ghcVersion = args.ghc.version;
      }).combined;
    };
  };

}
