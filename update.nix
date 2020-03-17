{ pkgs ? import ./nixpkgs.nix
}:
let
  inherit (pkgs) lib;
  hpkgs = pkgs.haskellPackages;
  runtimeDeps = [
    pkgs.nix-prefetch-scripts
    pkgs.git
    pkgs.haskellPackages.cabal-install
    pkgs.nix
    pkgs.coreutils
    pkgs.gawk
  ];
  pkg = (hpkgs.callCabal2nix "all-hies" (pkgs.lib.sourceByRegex ./. [
    "src.*"
    "all-hies.cabal"
  ]) {}).overrideAttrs (old: {
    nativeBuildInputs = old.nativeBuildInputs or [] ++ [
      pkgs.makeWrapper
    ];
    postInstall = old.postInstall or "" + ''
      wrapProgram $out/bin/update \
        --set PATH "${lib.makeBinPath runtimeDeps}" \
        --set LOCALE_ARCHIVE "${pkgs.glibcLocales}/lib/locale/locale-archive"
    '';
  });

  nix-tools = (import (fetchTarball "https://github.com/input-output-hk/haskell.nix/tarball/13a88d15f3bbcfd61d89dfe2dade093393d8c9e2" + "/ci.nix"))."release-19.03".tests.x86_64-linux.haskellNixRoots.nix-tools;

  src = pkgs.srcOnly {
    name = "haskell-ide-engine-source-patched";
    src = pkgs.fetchFromGitHub {
      owner = "haskell";
      repo = "haskell-ide-engine";
      rev = "1.2";
      sha256 = "01dxadc3p943150dsvqifpx49nrb3276hf4sr1r3bcgmzlgl8psz";
    };
    patches = [
      (pkgs.fetchpatch {
        url = "https://github.com/haskell/haskell-ide-engine/commit/4b8b573a559308094da5c33665f3e7167de446ba.patch";
        sha256 = "0vqafvmj81vxp48phha2nsdfj90axqv3r9nvrnspabrhsyavkr3p";
      })
    ];
  };

  updateScript = pkgs.writeShellScriptBin "update" ''
    find ${src} -maxdepth 1 \
      | ${pkgs.ripgrep}/bin/rg 'stack-([0-9]+)\.([0-9]+)\.([0-9]+)\.yaml$' -r '$0 ghc$1$2$3' \
      | while read file version; do
        ${nix-tools}/bin/stack-to-nix -o generated-new/$version --stack-yaml $file --cache /dev/null
      done
  '';

in {
  env = pkgs.mkShell {
    buildInputs = [
      updateScript
    ];
  };
}
