{ pkgs ? import ./nixpkgs.nix
}:

let
  ghcWithPkgs = pkgs.haskellPackages.ghcWithPackages (p: with p; [
    directory
    filepath
    process
    http-client
    http-client-tls
    aeson
    regex-applicative
    haskeline
    stack2nix
    cabal-install
  ]);
in

pkgs.mkShell {
  buildInputs = with pkgs; [
    ghcWithPkgs
    git
    nix-prefetch-scripts
  ];
}
