{ pkgs ? import ./nixpkgs.nix
}:
let
  inherit (pkgs) lib;
  hpkgs = pkgs.haskellPackages;
  pkg = hpkgs.callCabal2nix "all-hies" (pkgs.lib.sourceByRegex ./. [
    "update.hs"
    "all-hies.cabal"
  ]) {};
in pkg // {
  env = pkg.env.overrideAttrs (old: {
    nativeBuildInputs = old.nativeBuildInputs or [] ++ [
      pkgs.nix-prefetch-scripts
      pkgs.git
      pkgs.haskellPackages.cabal-install
    ];
  });
}
