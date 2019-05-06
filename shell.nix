{ pkgs ? import ./nixpkgs.nix
}:
(pkgs.haskellPackages.callCabal2nix "all-hies" ./. {}).env.overrideAttrs (old: {
  nativeBuildInputs = old.nativeBuildInputs or [] ++ [
    pkgs.nix-prefetch-scripts
    pkgs.git
    pkgs.haskellPackages.cabal-install
  ];
})
