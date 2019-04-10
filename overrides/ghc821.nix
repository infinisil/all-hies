let
  fixupPackageConfDir = pkg: pkg.overrideAttrs (old: {
    postInstall = ''

      # Fix for https://github.com/NixOS/nixpkgs/issues/32980
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

  haddock-library = fixupPackageConfDir super.haddock-library;
  cabal-plan = fixupPackageConfDir super.cabal-plan;

}
