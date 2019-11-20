# nixpkgs used only for library functions, not for dependencies
{ pkgs ? import ./nixpkgs.nix
, lib ? pkgs.lib
, fetchFromGitHub ? pkgs.fetchFromGitHub
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

  ghcSpecific = buildName: ghcVersion: rec {

    # Reformats the ghc version into the format "8.6.4"
    versionString = lib.concatStringsSep "."
      (builtins.match "ghc(.)(.)(.)" ghcVersion);

    # The more recent the version, the higher the priority
    # But higher priorities are lower on the number scale (WHY?), so we need the -
    versionPriority = - lib.toInt (lib.head (builtins.match "ghc(.*)" ghcVersion));

    # Evaluates to a nixpkgs that has the given ghc version in it
    pkgs = let
      rev = builtins.readFile (./nixpkgsForGhc + "/${ghcVersion}");
      sha256 = builtins.readFile (./generated + "/${buildName}/nixpkgsHashes/${rev}");
    in import (fetchFromGitHub {
      owner = "NixOS";
      repo = "nixpkgs";
      inherit sha256 rev;
    }) { config = {}; overlays = []; };

    # Returns a Haskell overlay that sets all ghc base libraries to null
    # (minus a select few)
    baseLibraryNuller = self: super: let
      libs = lib.splitString " "
        (builtins.readFile (./generated + "/${buildName}/ghcBaseLibraries/${ghcVersion}"));
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
  hieBuild = buildName: ghcVersion: let
    forGhc = ghcSpecific buildName ghcVersion;
    hlib = forGhc.pkgs.haskell.lib;
    revision = builtins.readFile (./generated + "/${buildName}/stack2nix/revision");

    hieOverride = self: super: {
      haskell-ide-engine = (hlib.overrideCabal super.haskell-ide-engine (old: {
        # Embed the ghc version into the name
        pname = "${old.pname}-${ghcVersion}";
        version = revision;

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

    expr = import (./generated + "/${buildName}/stack2nix/${ghcVersion}.nix") {
      pkgs = forGhc.pkgs;
    };

    build = (expr.override overrideFun).haskell-ide-engine;
  in build;

  # A set of all ghc versions for all hie versions, like
  # { stable = { ghc864 = <derivation ..>; ... }; unstable = ...; }
  # Each of which contain binaries hie and hie-$major.$minor.$patch for their
  # GHC version, along with a hie-wrapper binary that knows about this version
  allVersions = lib.mapAttrs (buildName: _:
    let ghcVersionFiles = lib.filterAttrs (file: _: file != "revision")
      (builtins.readDir (./generated + "/${buildName}/stack2nix"));
    in lib.mapAttrs' (ghcVersionFile: _:

      let ghcVersion = lib.removeSuffix ".nix" ghcVersionFile;
      in lib.nameValuePair ghcVersion (hieBuild buildName ghcVersion)

    ) ghcVersionFiles) (builtins.readDir ./generated);

  # Combine a set of HIE versions (given as { <ghcVersion> = <derivation>; })
  # into a single derivation with the following binaries:
  # - hie-*.*.*: The GHC specific HIE versions, such as ghc-8.6.4
  # - hie-wrapper: A HIE version that selects the appropriate version
  #     automatically out of the given ones
  # - hie: Same as hie-wrapper, provided for easy editor integration
  combined = versions: pkgs.buildEnv {
    name = "haskell-ide-engine-combined";
    paths = lib.attrValues versions;
    buildInputs = [ pkgs.makeWrapper ];
    pathsToLink = [ "/bin" ];
    extraPrefix = "/libexec";
    postBuild = ''
      # Remove hie/hie-wrapper in /libexec/bin because those are both just PATH
      # wrapped versions. Move the actual hie-wrapper to $out/bin
      rm $out/libexec/bin/{hie,hie-wrapper}
      mkdir -p $out/bin
      mv $out/libexec/bin/.hie-wrapper-wrapped $out/bin/hie-wrapper

      # Now /libexec/bin only contains binaries hie-*.*.*. Link all of them to
      # $out/bin such that users installing this directly can access these
      # specific versions too in $PATH
      for bin in $out/libexec/bin/*; do
        ln -s ../libexec/bin/$(basename $bin) $out/bin/$(basename $bin)
      done

      # Because we don't want hie-wrapper to fall back to hie binaries later in
      # PATH (because if this derivation is installed, a later hie might be
      # hie-wrapper itself, leading to infinite process recursion), we provide
      # our own hie binary instead, which will only be called if it couldn't
      # find any appropriate hie-*.*.* binary, in which case the user needs to
      # adjust their all-hies installation to make that one available.
      cat > $out/libexec/bin/hie << EOF
      #!${pkgs.runtimeShell}
      echo "hie-wrapper couldn't find a HIE binary with a matching GHC" \\
        "version in your all-hies installation" >&2
      exit 1
      EOF
      chmod +x $out/libexec/bin/hie

      # Wrap hie-wrapper with PATH prefixed with /libexec/bin, such
      # that it can find all those binaries. Not --suffix because
      # hie-wrapper needs to find our hie binary first and foremost as per
      # above comment, also makes it more reproducible. Not --set because hie
      # needs to find binaries for cabal/ghc and such.
      wrapProgram $out/bin/hie-wrapper \
        --prefix PATH : $out/libexec/bin

      # Make hie-wrapper available as hie as well, in order to minimize the need
      # for customizing editors, and to override a potential hie binary from
      # another derivation in the same environment.
      ln -s hie-wrapper $out/bin/hie
    '';
  };

  # Generates a set with the utility functions from a set of versions
  mkSet = versions: {
    inherit combined versions;
    selection = { selector }: combined (selector versions);
    latest = lib.last (lib.attrValues versions);
  };

in mkSet allVersions.stable
// lib.mapAttrs (_: mkSet) (builtins.removeAttrs allVersions ["stable"])
// {
  # Stable, but fall back to unstable if stable doesn't have a certain GHC
  # version
  unstableFallback = mkSet (allVersions.unstable // allVersions.stable);
}
