# nixpkgs used only for library functions, not for dependencies
{ allowBroken ? false }:

let

  inherit (import ./build.nix { inherit allowBroken; }) builds pkgs hieVersion;
  inherit (pkgs) lib;

  ghcSpecific = ghcVersion: rec {

    # The more recent the version, the higher the priority
    # But higher priorities are lower on the number scale (WHY?), so we need the -
    versionPriority = - lib.toInt (lib.head (builtins.match "ghc(.*)" ghcVersion));

  };


  # Build for a specific GHC version
  single = build:
    pkgs.runCommandNoCC "haskell-ide-engine-single-${build.version.dotVersion}-${hieVersion}" {
      nativeBuildInputs = [ pkgs.makeWrapper ];
      inherit (build.packages.hie) meta;
    } ''
      mkdir -p $out/bin
      ln -s ${build.packages.hie}/bin/hie $out/bin/hie
      ln -s hie $out/bin/hie-${build.version.dotVersion}
      ln -s ${build.packages.hie-bios}/bin/hie-bios $out/bin/hie-bios
      makeWrapper ${build.packages.hie-wrapper}/bin/hie-wrapper $out/bin/hie-wrapper \
        --suffix PATH : $out/bin
    '';

  # Combine a set of HIE versions (given as { <ghcVersion> = <derivation>; })
  # into a single derivation with the following binaries:
  # - hie-*.*.*: The GHC specific HIE versions, such as ghc-8.6.4
  # - hie-wrapper: A HIE version that selects the appropriate version
  #     automatically out of the given ones
  # - hie: Same as hie-wrapper, provided for easy editor integration
  combined = builds:
    let
      buildList = lib.attrValues builds;
      lastBuild = lib.last buildList;
      inherit (lastBuild.packages) hie-wrapper hie-bios;
    in pkgs.runCommandNoCC "haskell-ide-engine-combined-${hieVersion}" {
      nativeBuildInputs = [ pkgs.makeWrapper ];
      inherit (lastBuild.packages.hie) meta;
    } ''
      mkdir -p $out/bin $out/libexec/bin

      # Make hie-*.*.* links for all given versions
      ${lib.concatMapStringsSep "\n" (build: ''
        ln -s ${build.packages.hie}/bin/hie $out/libexec/bin/hie-${build.version.dotVersion}
      '') buildList}

      # Link all of hie-*.*.* from $out/libexec/bin to $out/bin such that users
      # installing this directly can access the specific version binaries too
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
      makeWrapper ${hie-wrapper}/bin/hie-wrapper $out/bin/hie-wrapper \
        --prefix PATH : $out/libexec/bin

      ln -s ${hie-bios}/bin/hie-bios $out/bin/hie-bios

      # Make hie-wrapper available as hie as well, in order to minimize the need
      # for customizing editors, and to override a potential hie binary from
      # another derivation in the same environment.
      ln -s hie-wrapper $out/bin/hie
    '';

in rec {
  inherit builds combined;
  versions = lib.mapAttrs (name: single) builds;
  selection = { selector }: combined (selector builds);
  latest = lib.last (lib.attrValues versions);

  unstable = throw "all-hies: Unstable versions are currently not supported";
  unstableFallback = throw "all-hies: Unstable fallback versions are currently not supported";
  bios = throw "all-hies: All versions now have hie-bios support, no need to use the bios attribute anymore";
}
