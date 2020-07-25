let
  build = import ./build.nix;
in final: prev:
let
  glibcName =
    if final.stdenv.hostPlatform.isDarwin
    # glibc matching doesn't matter for darwin
    then "glibc-2.30"
    else final.glibc.name;
in {

  haskell = prev.haskell // {
    packageOverrides = final.lib.composeExtensions prev.haskell.packageOverrides
      (hfinal: hprev: {
        hie = (build {
          inherit glibcName;
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
        inherit glibcName;
        ghcVersion = if args ? compiler-nix-name
                     then final.haskell-nix.compiler.${args.compiler-nix-name}.version
                     else args.ghc.version; # deprecated
      }).combined;
    };
  };

}
