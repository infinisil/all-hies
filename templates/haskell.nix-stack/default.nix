let
  haskellNixSrc = fetchTarball {
    url = "https://github.com/input-output-hk/haskell.nix/tarball/4219882774edb7a5e8382c3c6c421f2e907ee262";
    sha256 = "05ymnlnyx9hnb9i3zpppijz32kwk1am1pabchkpl9s4dh0qkkhim";
  };
  haskellNix = import haskellNixSrc {};

  all-hies = ../..;

  # Use this version for your project instead
  /*
  all-hies = fetchTarball {
	  # Insert the desired all-hies commit here
    url = "https://github.com/input-output-hk/haskell.nix/tarball/000000000000000000000000000000000000000";
		# Insert the correct hash after the first evaluation
    sha256 = "0000000000000000000000000000000000000000000000000000";
  };
  */

  pkgs = import haskellNix.sources.nixpkgs-2003 (haskellNix.nixpkgsArgs // {
    overlays = haskellNix.nixpkgsArgs.overlays ++ [
      (import all-hies {}).overlay
    ];
  });

  set = pkgs.haskell-nix.stackProject {
    name = "all-hies-template";
    src = pkgs.haskell-nix.haskellLib.cleanGit {
      name = "all-hies-template";
      src = ./.;
    };
    modules = [{
      # Make Cabal reinstallable
      nonReinstallablePkgs = [ "rts" "ghc-heap" "ghc-prim" "integer-gmp" "integer-simple" "base" "deepseq" "array" "ghc-boot-th" "pretty" "template-haskell" "ghcjs-prim" "ghcjs-th" "ghc-boot" "ghc" "Win32" "array" "binary" "bytestring" "containers" "directory" "filepath" "ghc-boot" "ghc-compact" "ghc-prim" "hpc" "mtl" "parsec" "process" "text" "time" "transformers" "unix" "xhtml" "terminfo" ];
    }];
  };
in set.all-hies-template.components.exes.all-hies-template // {
  env = set.shellFor {
    packages = p: [ p.all-hies-template ];
    #exactDeps = true;
    tools = {
      hie = "unstable";
    };
    nativeBuildInputs = [ pkgs.stack ];
    shellHook = ''
      export HIE_HOOGLE_DATABASE=$(realpath "$(dirname "$(realpath "$(which hoogle)")")/../share/doc/hoogle/default.hoo")
    '';
  };
  inherit pkgs;
}
