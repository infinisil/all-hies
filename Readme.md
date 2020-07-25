# Haskell IDE Engine for Nix

This project provides cached Nix builds for [Haskell IDE Engine](https://github.com/haskell/haskell-ide-engine) for GHC 8.6.5 and 8.8.3.

## Installation

Installation is done with your projects nix-shell environment. Both [haskell.nix](https://input-output-hk.github.io/haskell.nix/) and the nixpkgs Haskell infrastructure are supported. If you don't have a nix-shell environment for your project yet, I recommend using haskell.nix.

If you just want to get started, see the [templates](./templates) for fully working example projects.

### haskell.nix Projects

In short, to install HIE for your haskell.nix project, apply the all-hies nixpkgs overlay and add `{ hie = "unstable"; }` to the `tools` argument of [`shellFor`](https://input-output-hk.github.io/haskell.nix/reference/library/#shellfor). Finally, if you want to use the prebuilt binaries, use the `all-hies` cachix.

Applying the overlay can be done as follows in a recent haskell.nix version
```nix
let
  # Pin all-hies
  all-hies = fetchTarball {
    # Insert the desired all-hies commit here
    url = "https://github.com/infinisil/all-hies/tarball/000000000000000000000000000000000000000";
    # Insert the correct hash after the first evaluation
    sha256 = "0000000000000000000000000000000000000000000000000000";
  };

  # Assuming nixpkgs and haskellNix are defined here

  # Import nixpkgs with both haskell.nix's overlays and the all-hies one
  pkgs = import nixpkgs (haskellNix.nixpkgsArgs // {
    overlays = haskellNix.nixpkgsArgs.overlays ++ [
      (import all-hies {}).overlay
    ];
  };

  /* ... */
in /* ... */
```

Adding HIE to the environment is done like this in your `shellFor` call
```nix
shellFor {
  packages = p: [ p.my-package ];
  tools = {
    hie = "unstable";
  };
}
```

Configuring the `all-hies` cachix can be done with [these instructions](https://all-hies.cachix.org/), or if you have cachix installed already:
```shell
$ cachix use all-hies
```

Note that for haskell.nix in general, `cachix use iohk` saves a lot of building time if you use the same nixpkgs as IOHK's CI.

See the [haskell.nix template](./templates/haskell.nix) for a fully working example including a working cabal version and a hoogle database.

### nixpkgs Haskell infrastructure

In short, to install HIE for your project using nixpkgs Haskell infrastructure, apply the all-hies overlay and add the `hie` Haskell package to the `nativeBuildInputs` argument of `shellFor`. Finally, if you want to use the prebuilt binaries, use the `all-hies` cachix.

Applying the overlay can be done as follows
```nix
let
  # Pin all-hies
  all-hies = fetchTarball {
    # Insert the desired all-hies commit here
    url = "https://github.com/infinisil/all-hies/tarball/000000000000000000000000000000000000000";
    # Insert the correct hash after the first evaluation
    sha256 = "0000000000000000000000000000000000000000000000000000";
  };

  # Assuming nixpkgs is defined here

  # Import nixpkgs with the all-hies overlay
  pkgs = import nixpkgs {
    # Pass no config for purity
    config = {};
    overlays = [
      (import all-hies {}).overlay
    ];
  };

  /* ... */
in /* ... */
```

Adding HIE to the environment is done like this in your `shellFor` call
```nix
shellFor {
  packages = p: [ p.my-package ];
  nativeBuildInputs = [
    haskellPackages.hie
  ];
}
```

Configuring the `all-hies` cachix can be done with [these instructions](https://all-hies.cachix.org/), or if you have cachix installed already:
```shell
$ cachix use all-hies
```

See the [nixpkgs infra template](./templates/nixpkgs-infra) for a fully working example including a working cabal version and a hoogle database.
