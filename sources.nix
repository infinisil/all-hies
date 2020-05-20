let
  haskellNixSrc = fetchTarball {
    url = "https://github.com/input-output-hk/haskell.nix/tarball/af5998fe8d6b201d2a9be09993f1b9fae74e0082";
    sha256 = "0z5w99wkkpg2disvwjnsyp45w0bhdkrhvnrpz5nbwhhp21c71mbn";
  };
  haskellNix = import haskellNixSrc {};

  pkgs = import haskellNix.sources.nixpkgs-2003 haskellNix.nixpkgsArgs;

  hieVersion = "1.4";

  hieSrc = pkgs.srcOnly {
    name = "haskell-ide-engine-patched";
    src = pkgs.fetchzip {
      url = "https://github.com/haskell/haskell-ide-engine/tarball/${hieVersion}";
      sha256 = "15i01h6c5j2dvdyfajbcby0q0mjaiqb9q2kg9wfjzzjm50khb7rg";
    };
    patches = [
      (pkgs.fetchpatch {
        # https://github.com/haskell/haskell-ide-engine/pull/1770 for 1.4
        url = "https://github.com/haskell/haskell-ide-engine/commit/495d6cf513e090a8c5a40b95890440c8322d5d0c.patch";
        sha256 = "16hrsgf43k91zh5fc52hx8yvi1qcvkknhmcz3vvz0p8fx5sfdwyc";
      })
    ];
  };

in {
  inherit pkgs hieSrc hieVersion;
}
