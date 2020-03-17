{ haskellNixSrc ? fetchTarball "https://github.com/input-output-hk/haskell.nix/tarball/13a88d15f3bbcfd61d89dfe2dade093393d8c9e2"
, nixpkgs ? fetchTarball "https://github.com/input-output-hk/nixpkgs/tarball/a8f81dc037a5977414a356dd068f2621b3c89b60" }:

let
  pkgs = import nixpkgs (import haskellNixSrc);
  inherit (pkgs) lib;

  pkgSet = version: let
    ghc = pkgs.haskell-nix.compiler.${version} or (throw "Version ${version} not supported by haskell.nix");
    in pkgs.haskell-nix.mkStackPkgSet {
    stack-pkgs = import (./. + "/generated-new/${version}/pkgs.nix");
    pkg-def-extras = [];
    modules = [
      {
        ghc.package = ghc;
        compiler.version = pkgs.lib.mkForce ghc.version;
        packages.ghcide.configureFlags = [ "--enable-executable-dynamic" ];
        doHoogle = false;
        doCheck = false;
        doHaddock = false;
        dontStrip = false;
        enableSeparateDataOutput = true;
        reinstallableLibGhc = true;
      }
    ];
  };

in
  lib.mapAttrs (version: value: (pkgSet version).config.hsPkgs.haskell-ide-engine.components.exes.hie) (builtins.readDir ./generated-new)
