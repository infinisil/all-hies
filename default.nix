# nixpkgs used only for library functions, not for dependencies
{ pkgs ? import ./nixpkgs.nix
, lib ? pkgs.lib
}:

let

  # A la lib.composeExtensions, but with any number of extensions
  composeMultiple = extensions:
    if extensions == [] then self: super: {}
    else lib.composeExtensions
      (lib.head extensions)
      (composeMultiple (lib.tail extensions));

  # Speeds up Haskell builds
  speedierBuilds = self: super: {
    mkDerivation = args: super.mkDerivation (args // {
      enableLibraryProfiling = false;
    });
  };

  ghcSpecific = ghcVersion: rec {

    # Reformats the ghc version into the format "8.6.4"
    versionString = lib.concatStringsSep "."
      (builtins.match "ghc(.)(.)(.)" ghcVersion);

    # Evaluates to a nixpkgs that has the given ghc version in it
    pkgs = let
      rev = builtins.readFile (./nixpkgsForGhc + "/${ghcVersion}");
      sha256 = builtins.readFile (./generated/nixpkgsHashes + "/${rev}");
    in import (fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/tarball/${rev}";
      inherit sha256;
    }) { config = {}; overlays = []; };

    # Returns a Haskell overlay that sets all ghc base libraries to null
    # (minus a select few)
    baseLibraryNuller = self: super: let
      libs = lib.splitString " "
        (builtins.readFile (./generated/ghcBaseLibraries + "/${ghcVersion}"));
      libNames = map (lib: (builtins.parseDrvName lib).name) libs;
      # It seems that some versions require Cabal and some don't
      filtered = lib.filter (name: ! lib.elem name [ "ghc" "Cabal" ]) libNames;
    in lib.genAttrs filtered (name: null);

    # Custom overrides for specific ghc versions, declared in ./overrides
    customOverrides =
      let path = ./overrides + "/${ghcVersion}.nix";
      in if builtins.pathExists path then import path
      else self: super: {};
  };


  # Build for a specific GHC version
  hieBuild = ghcVersion: let
    forGhc = ghcSpecific ghcVersion;
    hlib = forGhc.pkgs.haskell.lib;
    revision = builtins.readFile ./generated/stack2nix/revision;

    # Embed the ghc version into the name
    changeName = self: super: {
      haskell-ide-engine = hlib.overrideCabal super.haskell-ide-engine (old: {
        pname = "${old.pname}-${ghcVersion}";
        version = lib.substring 0 8 revision;
      });
    };

    overrideFun = old: {
      overrides = composeMultiple [
        (old.overrides or (self: super: {}))
        speedierBuilds
        changeName
        forGhc.baseLibraryNuller
        forGhc.customOverrides
      ];
    };

    expr = import (./generated/stack2nix + "/${ghcVersion}.nix") {
      pkgs = forGhc.pkgs;
    };

    build = hlib.justStaticExecutables
      (expr.override overrideFun).haskell-ide-engine;

  in build;

  # A set of all ghc versions for all hie versions, like
  # { stable = { ghc864 = <derivation ..>; ... }; unstable = ...; }
  allVersions =
    let ghcVersionFiles = lib.filterAttrs (file: _: file != "revision")
      (builtins.readDir ./generated/stack2nix);
    in lib.mapAttrs' (ghcVersionFile: _:

      let ghcVersion = lib.removeSuffix ".nix" ghcVersionFile;
      in lib.nameValuePair ghcVersion (hieBuild ghcVersion)

    ) ghcVersionFiles;

  # Combined a set of HIE versions (given as { <ghcVersion> = <derivation>; })
  # into a single derivation which has a binary hie-$major.$minor.$patch for
  # every GHC version, and binaries hie and hie-wrapper containing a binary that
  # automatically selects the correct HIE version out of the available ghc
  # versions
  combined = nameSuffix: versions: let

    # This shouldn't matter, but let's use the hie-wrapper binary from the most
    # recent GHC version
    wrapperVersion = lib.last (lib.attrNames versions);

  in pkgs.runCommandNoCC "haskell-ide-engine-${nameSuffix}" {
    nativeBuildInputs = [ pkgs.makeWrapper ];
  } ''
    mkdir -p $out/bin

    ${lib.concatMapStringsSep "\n" (ghcVersion: ''
      ln -s ${versions.${ghcVersion}}/bin/hie $out/bin/hie-${(ghcSpecific ghcVersion).versionString}
    '') (lib.attrNames versions)}

    makeWrapper ${versions.${wrapperVersion}}/bin/hie-wrapper $out/bin/hie-wrapper \
      --suffix PATH : $out/bin

    ln -s hie-wrapper $out/bin/hie
  '';

  #inherit (versions) stable unstable;

  #makeSet = versions: combine versions // rec {
  #  inherit versions;
  #  latest = versions.${last (attrNames versions)};
  #  select = selector: makeSet (selector versions);
  #  minors = mapAttrs (name: makeSet)
  #    (foldl' (acc: el: let minor = lib.substring 0 (lib.stringLength el - 1) el; in 
  #      acc // {
  #        ${minor} = acc.${minor} or {} // { ${el} = versions.${el}; };
  #      }
  #    ) {} (lib.attrNames versions));
  #  from = mapAttrs (lower: _: makeSet (filterAttrs (version: _: versionAtLeast version lower) versions)) versions;
  #  to = mapAttrs (upper: _: makeSet (filterAttrs (version: _: versionAtLeast upper version) versions)) versions;
  #};

in {

  inherit combined allVersions;

  selection = { selector }: combined "selection"
    (selector (builtins.intersectAttrs (lib.functionArgs selector) allVersions));

  combos = {
    all = combined "all" allVersions.stable;
  };

}
