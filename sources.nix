let
  haskellNixSrc = fetchTarball {
    url = "https://github.com/input-output-hk/haskell.nix/tarball/af5998fe8d6b201d2a9be09993f1b9fae74e0082";
    sha256 = "0z5w99wkkpg2disvwjnsyp45w0bhdkrhvnrpz5nbwhhp21c71mbn";
  };
  haskellNix = import haskellNixSrc {};

  pkgs = import haskellNix.sources.nixpkgs-2003 haskellNix.nixpkgsArgs;

  # unstable-2020-05-23
  hieVersion = "fe630a1e31232013549518909e511924e19af4af";

  hieSrc = fetchTarball {
    url = "https://github.com/haskell/haskell-ide-engine/archive/${hieVersion}.tar.gz";
    sha256 = "1lbbzk9kj39h79wb8imv5s22y592cyyrk06y24glrcxh5bzghb9l";
  };

in {
  inherit pkgs hieSrc hieVersion;
}
