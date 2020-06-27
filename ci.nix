{ glibcVersion, ghcVersion }: let
  sources = import ./sources.nix;
  inherit (sources) pkgs;
  inherit (pkgs) lib;
in import ./build.nix {
  pkgs = sources.glibcSpecificPkgs."glibc-${glibcVersion}";
  inherit sources ghcVersion;
}