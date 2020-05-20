{ allowBroken ? false }:
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
      haskellSet = pkgs.haskell-nix.stackProject' ({
        src = sources.hieSrc;
        stackYaml = "stack-${dotVersion}.yaml";
        ghc = pkgs.haskell-nix.compiler."ghc${tightVersion}";
        modules = [{
          reinstallableLibGhc = true;
          doHaddock = false;
          packages.ghc.flags.ghci = true;
          packages.ghci.flags.ghci = true;
          packages.haskell-ide-engine.configureFlags = [ "--enable-executable-dynamic" ];
        }];
      } // lib.optionalAttrs (builtins.pathExists generatedDir) {
        stack-sha256 = lib.fileContents hashFile;
        materialized = materializedDir;
      });

      materializeScript = pkgs.writeShellScriptBin "materialize-${version.dotVersion}" ''
        set -x
        mkdir -p ${toString generatedDir}
        nix-hash --base32 --type sha256 ${haskellSet.stack-nix} > ${toString hashFile}
        cp -r --no-preserve=mode ${haskellSet.stack-nix} ${toString materializedDir}
      '';

    in {
      inherit haskellSet;
      inherit materializeScript;
    };


in {

  inherit pkgs;

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
    in lib.listToAttrs (map (version: lib.nameValuePair "ghc${version.tightVersion}" (
      let
        inherit (res version) haskellSet;
        inherit (haskellSet.hsPkgs.haskell-ide-engine.components.exes) hie hie-wrapper;
        inherit (haskellSet.hsPkgs.hie-bios.components.exes) hie-bios;

        brokenVersions = [
          "8.4.4"
          "8.6.4"
          "8.8.2"
        ];

        brokenMessage = ''
          all-hies: The build for haskell-ide-engine ${sources.hieVersion} with GHC ${version.dotVersion} is currently broken.

          To ignore this error and attempt a build nevertheless, import all-hies with

            import (fetchTarball "https://github.com/infinisil/all-hies/tarball/master") {
              allowBroken = true;
            }

          Maybe you can help fixing it?
        '';
        brokenHie = if allowBroken then hie else throw brokenMessage;

      in {
        inherit haskellSet version;
        packages = {
          inherit hie-wrapper hie-bios;
          hie = if lib.elem version.dotVersion brokenVersions then brokenHie else hie;
        };
      })
    ) versions);

  inherit (sources) hieVersion;

}
