{ ghcVersion, glibcName }:
let
  sources = import ./sources.nix;
  pkgs = sources.glibcSpecificPkgs.${glibcName} or (throw "all-hies: A nixpkgs with ${glibcName} is currently not supported. ");
  inherit (pkgs) lib;

  versionList = builtins.match "([0-9]+)\\.([0-9]+)\\.([0-9]+)" ghcVersion;
  version = rec {
    major = lib.elemAt versionList 0;
    minor = lib.elemAt versionList 1;
    patch = lib.elemAt versionList 2;
    dotVersion = "${major}.${minor}.${patch}";
    tightVersion = "${major}${minor}${patch}";
  };

  supportedVersions = [ "8.6.5" "8.8.3" ];
  unsupportedWarning = if lib.elem ghcVersion supportedVersions then lib.id else lib.warn "all-hies: GHC version ${ghcVersion} is not supported, no caches are available and the build will probably fail";

  stackArgs = {
    src = sources.hie.src;
    stackYaml = "stack-${version.dotVersion}.yaml";
    # TODO: Remove GHC from closure
    modules = [{
      reinstallableLibGhc = true;
      doHaddock = false;
      packages.ghc.flags.ghci = true;
      packages.ghci.flags.ghci = true;
      packages.haskell-ide-engine.configureFlags = [ "--enable-executable-dynamic" ];
    }];
  };

  generatedDir = ./generated + "/${version.dotVersion}";
  hashFile = generatedDir + "/stack-sha256";
  materializedDir = generatedDir + "/materialized";

  materializedStackArgs = stackArgs // lib.optionalAttrs (builtins.pathExists generatedDir) {
    stack-sha256 = lib.fileContents hashFile;
    materialized = materializedDir;
  };

  combined =
    let
      haskellSet = pkgs.haskell-nix.stackProject materializedStackArgs;
      inherit (haskellSet.haskell-ide-engine.components.exes) hie;
      inherit (haskellSet.hie-bios.components.exes) hie-bios;
    in (pkgs.buildEnv {
      name = "haskell-ide-engine-${version.dotVersion}-${sources.hie.version}";
      paths = [ hie hie-bios ];
      pathsToLink = [ "/bin" ];
      postBuild = "ln -s hie $out/bin/hie-wrapper";
      inherit (hie) meta;
    }).overrideAttrs (old: {
      allowSubstitutes = true;
    });

  materialize =
    let
      haskellSet = pkgs.haskell-nix.stackProject stackArgs;
    in pkgs.writeShellScript "materialize-${version.dotVersion}" ''
      set -x
      mkdir -p ${toString generatedDir}
      nix-hash --base32 --type sha256 ${haskellSet.stack-nix} > ${toString hashFile}
      ${pkgs.coreutils}/bin/cp -r --no-preserve=mode -T ${haskellSet.stack-nix} ${toString materializedDir}
      cp ${sources.materializationId} ${toString generatedDir}/materialization-id
    '';

in unsupportedWarning {
  inherit combined materialize;
}
