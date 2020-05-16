let
  sources = import ./sources.nix;
  inherit (sources) pkgs;
  inherit (pkgs) lib;

  toVersionSet = list: rec {
    major = lib.elemAt list 0;
    minor = lib.elemAt list 1;
    patch = lib.elemAt list 2;
    dotVersion = "${major}.${minor}.${patch}";
    tightVersion = "${major}${minor}${patch}";
  };

  res = version:
    let
      dotVersion = "${version.major}.${version.minor}.${version.patch}";
      tightVersion = "${version.major}${version.minor}${version.patch}";
      generatedDir = ./generated + "/${dotVersion}";
      hashFile = generatedDir + "/stack-sha256";
      materializedDir = generatedDir + "/materialized";
      set = pkgs.haskell-nix.stackProject' ({
        src = sources.hieSrc;
        stackYaml = "stack-${dotVersion}.yaml";
        ghc = pkgs.haskell-nix.compiler."ghc${tightVersion}";
        modules = [{
          reinstallableLibGhc = true;
          doHaddock = false;
        }];
      } // lib.optionalAttrs (builtins.pathExists generatedDir) {
        stack-sha256 = lib.fileContents hashFile;
        materialized = materializedDir;
      });

      materializeScript = pkgs.writeShellScriptBin "materialize-${version.dotVersion}" ''
        set -x
        mkdir -p ${toString generatedDir}
        nix-hash --base32 --type sha256 ${set.stack-nix} > ${toString hashFile}
        cp -r --no-preserve=mode ${set.stack-nix} ${toString materializedDir}
      '';

    in {
      inherit (set) hsPkgs;
      inherit materializeScript;
    };

in {

  materializeScript =
    let

      hieVersions =
        let
          rootPaths = lib.attrNames (builtins.readDir sources.hieSrc);
          matchVersion = builtins.match "stack-([0-9]+)\\.([0-9]+)\\.([0-9]+)\\.yaml";
        in map toVersionSet (lib.filter (x: x != null) (map matchVersion rootPaths));

      supportedByHaskellNix = version: pkgs.haskell-nix.compiler ? "ghc${version.tightVersion}";
      versions = lib.filter supportedByHaskellNix hieVersions;

    in pkgs.writeShellScriptBin "update" ''
      set -x
      rm -r ${toString ./generated}
      ${lib.concatMapStringsSep "\n" (version: "${(res version).materializeScript}/bin/materialize-${version.dotVersion}") versions}
    '';

  builds =
    let
      generatedDirs = lib.attrNames (builtins.readDir ./generated);
      matchVersion = builtins.match "([0-9]+)\\.([0-9]+)\\.([0-9]+)";
      versions = map (path: toVersionSet (matchVersion path)) generatedDirs;
      versionResult = version: (res version).hsPkgs.haskell-ide-engine.components.exes.hie;
    in lib.listToAttrs (map (version: lib.nameValuePair "ghc${version.tightVersion}" (versionResult version)) versions);
}
