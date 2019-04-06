with import <nixpkgs/lib>;
with builtins;

let


  pkgsForGhc = mapAttrs (ghc: _: let
    rev = readFile (./nixpkgsForGhc + "/${ghc}");
    sha256 = readFile (./nixpkgsHashes + "/${rev}");
  in
    import (fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/${rev}.tar.gz";
      inherit sha256;
    }) {
      config = {};
      overlays = [];
    })
    (readDir ./nixpkgsForGhc);
    
  version = name:
    mapAttrs' (file: _: let
      ghcVersion = removeSuffix ".nix" file;
      pkgs = pkgsForGhc.${ghcVersion};
      inherit (pkgs) lib haskell;

      overrideFun = old: {
        overrides = lib.composeExtensions
          (lib.composeExtensions
            (old.overrides or (self: super: {}))
            (hself: hsuper: {

              # Disable library profiling for faster builds
              mkDerivation = args: hsuper.mkDerivation (args // {
                enableLibraryProfiling = false;
              });

              # Embed the ghc version into the name
              haskell-ide-engine = haskell.lib.overrideCabal hsuper.haskell-ide-engine (old: {
                pname = "${old.pname}-${ghcVersion}";
              });
            }
            // lib.flip genAttrs (name: null)
              (lib.filter (name: name != "ghc" && name != "Cabal")
                (map (name: (builtins.parseDrvName name).name)
                  (lib.splitString " "
                    (builtins.readFile (./ghcBaseLibraries + "/${ghcVersion}")))))
            )
          )
          (if builtins.pathExists (./overrides + "/${ghcVersion}.nix") then
            import (./overrides + "/${ghcVersion}.nix")
            else self: super: {}
          );
      };

      build = haskell.lib.justStaticExecutables
        ((import (./versions + "/${name}/${file}") {
          inherit pkgs;
        }).override overrideFun).haskell-ide-engine;
    in {
      name = ghcVersion;
      value = build;
    }) 
    (filterAttrs (file: _: file != "revision") (readDir (./versions + "/${name}")));

  versions = mapAttrs (file: _: version file) (readDir ./versions);

  pkgs = import <nixpkgs> {};
  lib = pkgs.lib;

  parseNixGhcVersion = version:
    lib.concatStringsSep "." (builtins.match "ghc(.)(.)(.)" version);

  combine = versions: let
    wrapperVersion = lib.last (lib.attrNames versions);
  in pkgs.runCommand "haskell-ide-engine-combined" {
    nativeBuildInputs = [ pkgs.makeWrapper ];
  } ''
    mkdir -p $out/bin

    ${concatMapStringsSep "\n" (ghcVersion: ''
      ln -s ${versions.${ghcVersion}}/bin/hie $out/bin/hie-${parseNixGhcVersion ghcVersion}
    '') (lib.attrNames versions)}

    makeWrapper ${versions.${wrapperVersion}}/bin/hie-wrapper $out/bin/hie-wrapper \
      --suffix PATH : $out/bin
    ln -s hie-wrapper $out/bin/hie
  '';

  inherit (versions) stable unstable;

  makeSet = versions: combine versions // {
    inherit versions;
    select = selector: makeSet (selector versions);
    minors = mapAttrs (name: makeSet)
      (foldl' (acc: el: let minor = lib.substring 0 (lib.stringLength el - 1) el; in 
        acc // {
          ${minor} = acc.${minor} or {} // { ${el} = versions.${el}; };
        }
      ) {} (lib.attrNames versions));
  };

  result = makeSet (unstable // stable) // {
    onlyStable = makeSet stable;
    onlyUnstable = makeSet unstable;
    allVersions = versions;
  };

in result
