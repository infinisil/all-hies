let
  bootPkgs = import <nixpkgs> {};
  # TODO: Remove impurity when PR merged or addressed
  haskellNixSrc = bootPkgs.srcOnly {
    name = "haskell.nix-patched";
    src = fetchTarball {
      url = "https://github.com/input-output-hk/haskell.nix/tarball/f330b2407ea303e894e7ea208935faf234b8d753";
      sha256 = "0yymbii6lsm2skj6xq79gznhm4z2fy4hvl6nbffswxadlmnvj6s7";
    };
    patches = [
      (bootPkgs.fetchpatch {
        # https://github.com/input-output-hk/haskell.nix/pull/606
        url = "https://github.com/input-output-hk/haskell.nix/commit/8293b6d130366eab96b26993470a19b85a86d030.patch";
        sha256 = "0zd500zyd90iwrh20vrslzxxlka8z73g1dyw8a44axp8r6if7d28";
      })
    ];
  };
  haskellNix = import haskellNixSrc {};

  pkgs = import haskellNix.sources.nixpkgs-2003 haskellNix.nixpkgsArgs;

  hieSrc = pkgs.srcOnly {
    name = "haskell-ide-engine-patched";
    src = fetchTarball {
      url = "https://github.com/haskell/haskell-ide-engine/tarball/1.4";
      sha256 = "15i01h6c5j2dvdyfajbcby0q0mjaiqb9q2kg9wfjzzjm50khb7rg";
    };
    patches = [
      (pkgs.fetchpatch {
        # https://github.com/haskell/haskell-ide-engine/pull/1770 for 1.4
        url = "https://github.com/haskell/haskell-ide-engine/commit/495d6cf513e090a8c5a40b95890440c8322d5d0c.patch";
        sha256 = "16hrsgf43k91zh5fc52hx8yvi1qcvkknhmcz3vvz0p8fx5sfdwyc";
      })
    ];
  };
in {
  inherit pkgs hieSrc;
}
