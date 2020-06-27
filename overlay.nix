let
  sources = import ./sources.nix;
  build = import ./build.nix;
in final: prev: {
  haskell-nix = final.lib.recursiveUpdate prev.haskell-nix {
    # TODO: Add argument allowing not using prebuilt binaries
    custom-tools.hie.unstable = args: (build {
      pkgs = sources.glibcSpecificPkgs.${final.glibc.name};
      inherit sources;
      ghcVersion = args.ghc.version;
    }).combined;
  };

  haskell = prev.haskell // {
    packageOverrides = final.lib.composeExtensions prev.haskell.packageOverrides
      (hfinal: hprev: {
        hie = (build {
          pkgs = sources.glibcSpecificPkgs.${final.glibc.name};
          inherit sources;
          ghcVersion = hfinal.ghc.version;
        }).combined;
      });
  };
}
