let
  # Fix for https://github.com/NixOS/nixpkgs/issues/33149
  fixupInternalLibsDarwin = pkg: pkg.overrideAttrs (old: {
    setupCompilerEnvironmentPhase = builtins.replaceStrings
      [ "awk '{print $2}'" ] [ "awk '{print $2}' | sort -u" ] old.setupCompilerEnvironmentPhase;
  });

  # Fix for https://github.com/NixOS/nixpkgs/issues/32980
  fixupPackageConfDir = pkg: pkg.overrideAttrs (old: {
    postInstall = ''

      tmp=$(mktemp -d)
      for f in $packageConfDir/.conf/*; do
        mv "$f" "$tmp"
      done
      rmdir $packageConfDir/.conf
      for f in "$tmp"/*; do
        mv "$f" "$packageConfDir/$(basename "$f").conf"
      done
      rmdir "$tmp"

    '';
  });
in

self: super: {

  haddock-api = fixupInternalLibsDarwin super.haddock-api;
  cabal-helper = fixupInternalLibsDarwin super.cabal-helper;
  ghc-mod-core = fixupInternalLibsDarwin super.ghc-mod-core;
  HaRe = fixupInternalLibsDarwin super.HaRe;
  ghc-mod = fixupInternalLibsDarwin super.ghc-mod;
  hie-plugin-api = fixupInternalLibsDarwin super.hie-plugin-api;
  haskell-ide-engine = fixupInternalLibsDarwin super.haskell-ide-engine;

  haddock-library = fixupPackageConfDir super.haddock-library;
  cabal-plan = fixupPackageConfDir super.cabal-plan;

}
