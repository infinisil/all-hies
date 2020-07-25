# Nix-based Haskell project template using [haskell.nix](https://input-output-hk.github.io/haskell.nix/)

This template has support for:
- Building the project with Nix
- Entering a dev environment with Nix, which includes
  - GHC and cabal-install for the `cabal` command
  - All the projects Haskell dependencies
  - Haskell IDE Engine with a working Cabal version
  - An up-to-date local Hoogle database, usable by HIE
- Minimal compilation since most things are cached already

It uses the haskell.nix Haskell infrastructure for this.

# Usage

## Setting up the caches

To use this, you should first enable the necessary Nix caches so that most things don't have to be compiled. This is done using [Cachix](https://cachix.org/). If you don't have it already, you can install cachix with

```
$ nix-env -iA cachix -f https://cachix.org/api/v1/install
```

After which you can enable the `all-hies` and `iohk` caches, both of which are recommended for this template:

```
$ cachix use all-hies
$ cachix use iohk
```

## Entering the dev environment

This can be done either using `nix-shell`:

```
$ nix-shell
[nix-shell:~/all-hies/templates/haskell.nix-cabal]$
```

Or automatically when you enter the project directory using [direnv](https://direnv.net/) or [lorri](https://github.com/target/lorri) (by running `lorri init` first). Note that entering the environment the first time will take quite some time due to how haskell.nix works.

After entering the environment you can use the standard `cabal` commands for interacting with the project. Note that these will use all dependencies from Nix:
```
$ cabal build   # building the project
$ cabal repl    # Getting a ghci repl
$ cabal run     # Running an executable
```

In this environment HIE is available, which you can verify works with the `hie` command:

```
$ hie
[...]
/home/infinisil/all-hies/templates/haskell.nix-cabal/Main.hs: OK
```

The easiest way to get your editor to find HIE is to just start it in this environment:
```
$ vim
$ emacs
$ code
$ sublime
$ atom
```

Note that you still need to set up the necessary editor extensions yourself. See [here](https://github.com/haskell/haskell-ide-engine#editor-integration) for how to do this

A local Hoogle database is also available with all the dependencies of the project, which is used by HIE. You can start a hoogle server using
```
$ hoogle server
Server started on port 8080
Reading log...0.00s
2020-07-25T01:29:13.173630988 - Server starting on port 8080 and host/IP HostAny
```

## Building the project with Nix

This is done with just a `nix-build` in the root.
```
$ nix-build
```
