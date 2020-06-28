let
  nixpkgs = fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/tarball/f8248ab6d9e69ea9c07950d73d48807ec595e923";
    sha256 = "009i9j6mbq6i481088jllblgdnci105b2q4mscprdawg3knlyahk";
  };
  pkgs = import nixpkgs {
    config = {};
    overlays = [
      (import ../../overlay.nix)
    ];
  };
  inherit (pkgs) lib;

  set = pkgs.haskell.packages.ghc865.override (old: {
    overrides = lib.composeExtensions old.overrides (hself: hsuper: {
      all-hies-template = hself.callCabal2nix "all-hies-template" (lib.sourceByRegex ./. [
        "^.*\\.hs$"
        "^.*\\.cabal$"
      ]) {
        # Needs to match cabal-install version
        Cabal = hself.Cabal_3_0_0_0;
      };
    });
  });

in pkgs.haskell.lib.justStaticExecutables set.all-hies-template // {
  env = set.shellFor {
    packages = p: [ p.all-hies-template ];
    nativeBuildInputs = [
      set.cabal-install
      set.hie
    ];
    withHoogle = true;
    shellHook = ''
      export HIE_HOOGLE_DATABASE=$(realpath "$(dirname "$(realpath "$(which hoogle)")")/../share/doc/hoogle/default.hoo")
    '';
  };
  inherit set;
}
