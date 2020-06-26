{ pkgs, sources, ghcVersion, materialize }:
let
  inherit (pkgs) lib;

  versionList = builtins.match "([0-9]+)\\.([0-9]+)\\.([0-9]+)" ghcVersion;
  version = rec {
    major = lib.elemAt versionList 0;
    minor = lib.elemAt versionList 1;
    patch = lib.elemAt versionList 2;
    dotVersion = "${major}.${minor}.${patch}";
    tightVersion = "${major}${minor}${patch}";
  };

  generatedDir = ./generated + "/${version.dotVersion}";
  hashFile = generatedDir + "/stack-sha256";
  materializedDir = generatedDir + "/materialized";

  haskellSet = pkgs.haskell-nix.stackProject' ({
    src = sources.hie.src;
    stackYaml = "stack-${version.dotVersion}.yaml";
    ghc = pkgs.haskell-nix.compiler."ghc${version.tightVersion}";
    # TODO: Remove GHC from closure
    modules = [{
      reinstallableLibGhc = true;
      doHaddock = false;
      packages.ghc.flags.ghci = true;
      packages.ghci.flags.ghci = true;
      packages.haskell-ide-engine.configureFlags = [ "--enable-executable-dynamic" ];
    }];
  } // lib.optionalAttrs (materialize && builtins.pathExists generatedDir) {
    stack-sha256 = lib.fileContents hashFile;
    materialized = materializedDir;
  });

  materializeScript = pkgs.writeShellScript "materialize-${version.dotVersion}" ''
    set -x
    mkdir -p ${toString generatedDir}
    nix-hash --base32 --type sha256 ${haskellSet.stack-nix} > ${toString hashFile}
    cp -r --no-preserve=mode ${haskellSet.stack-nix} ${toString materializedDir}
  '';

  inherit (haskellSet.hsPkgs.haskell-ide-engine.components.exes) hie;
  inherit (haskellSet.hsPkgs.hie-bios.components.exes) hie-bios;

  combined = pkgs.buildEnv {
    name = "haskell-ide-engine-${version.dotVersion}-${sources.hie.version}";
    paths = [ hie hie-bios ];
    pathsToLink = [ "/bin" ];
    inherit (hie) meta;
  };
in {
  inherit combined materializeScript;
}
