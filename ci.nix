{ glibcVersion, ghcVersion }: let
  sources = import ./sources.nix;
  inherit (sources) pkgs;
  inherit (pkgs) lib;
in import ./build.nix {
  glibcName = "glibc-${glibcVersion}";
  inherit sources ghcVersion;
}
