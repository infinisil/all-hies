{ pkgs ? import ./nixpkgs.nix
}:
let
  inherit (pkgs) lib;
  hpkgs = pkgs.haskellPackages;
  path = lib.makeBinPath [
    pkgs.nix-prefetch-scripts
    pkgs.git
  ];
  pkg = (hpkgs.callCabal2nix "all-hies" (pkgs.lib.sourceByRegex ./. [
    "update.hs"
    "all-hies.cabal"
  ]) {}).overrideAttrs (old: {
    nativeBuildInputs = old.nativeBuildInputs or [] ++ [
      pkgs.makeWrapper
    ];
    postInstall = old.postInstall or "" + ''
      wrapProgram $out/bin/update \
        --set PATH "${path}"
    '';
  });
in pkg // {
  env = pkg.env.overrideAttrs (old: {
    nativeBuildInputs = old.nativeBuildInputs or [] ++ [
      pkgs.nix-prefetch-scripts
      pkgs.git
      pkgs.haskellPackages.cabal-install
    ];
  });
}
