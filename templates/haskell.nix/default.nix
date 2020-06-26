let
  haskellNixSrc = fetchTarball {
    url = "https://github.com/input-output-hk/haskell.nix/tarball/af5998fe8d6b201d2a9be09993f1b9fae74e0082";
    sha256 = "0z5w99wkkpg2disvwjnsyp45w0bhdkrhvnrpz5nbwhhp21c71mbn";
  };
  haskellNix = import haskellNixSrc {};

  pkgs = import haskellNix.sources.nixpkgs-2003 (haskellNix.nixpkgsArgs // {
    overlays = haskellNix.nixpkgsArgs.overlays ++ [
      (import ../../overlay.nix)
    ];
  });

  set = pkgs.haskell-nix.cabalProject' {
    name = "all-hies-template";
    src = pkgs.haskell-nix.haskellLib.cleanGit {
      name = "all-hies-template";
      src = ./.;
    };
    ghc = pkgs.buildPackages.pkgs.haskell-nix.compiler.ghc865;
    modules = [{
      # Make Cabal reinstallable
      nonReinstallablePkgs = [ "rts" "ghc-heap" "ghc-prim" "integer-gmp" "integer-simple" "base" "deepseq" "array" "ghc-boot-th" "pretty" "template-haskell" "ghcjs-prim" "ghcjs-th" "ghc-boot" "ghc" "Win32" "array" "binary" "bytestring" "containers" "directory" "filepath" "ghc-boot" "ghc-compact" "ghc-prim" "hpc" "mtl" "parsec" "process" "text" "time" "transformers" "unix" "xhtml" "terminfo" ];
    }];
  };
in set.hsPkgs.all-hies-template.components.exes.all-hies-template // {
  env = set.hsPkgs.shellFor {
    packages = p: [ p.all-hies-template ];
    exactDeps = true;
    tools = {
      cabal = "3.2.0.0";
      hie = "unstable";
    };
    shellHook = ''
      export HIE_HOOGLE_DATABASE=$(realpath "$(dirname "$(realpath "$(which hoogle)")")/../share/doc/hoogle/default.hoo")
    '';
  };
}
