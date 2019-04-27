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

    # The more recent the version, the higher the priority
    # But higher priorities are lower on the number scale (WHY?), so we need the -
    versionPriority = - lib.toInt (lib.head (builtins.match "ghc(.*)" ghcVersion));

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

    hieOverride = self: super: {
      haskell-ide-engine = (hlib.overrideCabal super.haskell-ide-engine (old: {
        # Embed the ghc version into the name
        pname = "${old.pname}-${ghcVersion}";
        version = lib.substring 0 8 revision;

        # Link Haskell libraries dynamically, improves startup time for projects
        # using TH by a lot (40x faster in one of my tests), but also Increases
        # closure size by about 50% (=~ 1.2GB) per HIE version
        # Can be disabled again for GHC versions that have a fix for
        # https://gitlab.haskell.org/ghc/ghc/issues/15524
        enableSharedExecutables = true;
        isLibrary = false;
        doHaddock = false;
      })).overrideAttrs (old: {
        nativeBuildInputs = old.nativeBuildInputs or [] ++ [ pkgs.makeWrapper ];
        # Make sure hie-x.x.x binary exists
        # And make sure hie-wrapper finds this version
        postInstall = old.postInstall or "" + ''
          ln -s hie $out/bin/hie-${forGhc.versionString}
          wrapProgram $out/bin/hie-wrapper \
            --suffix PATH : $out/bin
        '';

        # Assign a priority for allowing multiple versions to be installed at once
        meta = old.meta // {
          priority = forGhc.versionPriority;
        };
      });
    };

    overrideFun = old: {
      overrides = composeMultiple [
        (old.overrides or (self: super: {}))
        speedierBuilds
        hieOverride
        forGhc.baseLibraryNuller
        forGhc.customOverrides
      ];
    };

    expr = import (./generated/stack2nix + "/${ghcVersion}.nix") {
      pkgs = forGhc.pkgs;
    };

    build = (expr.override overrideFun).haskell-ide-engine;
  in build;

  # A set of all ghc versions for all hie versions, like
  # { stable = { ghc864 = <derivation ..>; ... }; unstable = ...; }
  # Each of which contain binaries hie and hie-$major.$minor.$patch for their
  # GHC version, along with a hie-wrapper binary that knows about this version
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
  combined = versions: pkgs.buildEnv {
    name = "haskell-ide-engine-combined";
    paths = lib.attrValues versions;
    buildInputs = [ pkgs.makeWrapper ];
    pathsToLink = [ "/bin" ];
    postBuild = ''
      rm $out/bin/hie-wrapper
      makeWrapper $out/bin/.hie-wrapper-wrapped $out/bin/hie-wrapper \
        --suffix PATH : $out/bin
      ln -sf hie-wrapper $out/bin/hie
    '';
  };

in {

  inherit combined;
  versions = allVersions;
  selection = { selector }: combined (selector allVersions);
  latest = lib.last (lib.attrValues allVersions);

}
