with import <nixpkgs/lib>;
with builtins;

let

  nixpkgsForGhc = mapAttrs (file: _: readFile (./nixpkgsForGhc + "/${file}"))
    (readDir ./nixpkgsForGhc);
    
  version = name:
    mapAttrs' (file: _: let
      ghcVersion = removeSuffix ".nix" file;
      pkgs = import (fetchGit {
        url = "https://github.com/NixOS/nixpkgs";
        rev = nixpkgsForGhc.${ghcVersion};
      }) {};
      build = pkgs.haskell.lib.justStaticExecutables
        (import (./versions + "/${name}/${file}") {
          inherit pkgs;
        }).haskell-ide-engine;
    in if hasSuffix ".nix" file then {
      name = ghcVersion;
      value = build;
    } else {
      name = file;
      value = builtins.readFile (./versions + "/${name}/${file}");
    })
    (readDir (./versions + "/${name}"));

in rec {

  versions = mapAttrs (file: _: version file) (readDir ./versions);

  forGhc = versions.unstable // versions.stable;

  # forGhcs (p: [ p.ghc864 p.ghc863 ])
  forGhcs = selector: null;

}
