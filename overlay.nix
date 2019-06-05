# This overlay adds a haskell-ide-engine package to all Haskell package sets
# that have a supported GHC version.

# In the future arguments like `withUnstable` or so might be added
{}:

self: super:

let

  inherit (super) lib;

  all-hies = import ./. {};

  hieOverride = name: old: {
    overrides = lib.composeExtensions (old.overrides or (hself: hsuper: {})) (hself: hsuper: {
      haskell-ide-engine = all-hies.versions.${name} or (throw
        ( "haskell-ide-engine stable version ${all-hies.version} doesn't have "
        + "support for GHC version ${name}. "
        + "Supported versions are ${toString (lib.attrNames all-hies.versions)}."));
    });
  };

in {

  # Needed for the foreseeable future until everybody has
  # https://github.com/NixOS/nixpkgs/pull/62742
  haskellPackages = super.haskellPackages.override (old:
  let
    split = builtins.splitVersion (builtins.parseDrvName old.ghc.name).version;
    name = "ghc${lib.elemAt split 0}${lib.elemAt split 1}${lib.elemAt split 2}";
  in hieOverride name old);

  haskell = super.haskell // {
    packages = super.lib.mapAttrs (name: packages:
      packages.override (hieOverride name)
    ) super.haskell.packages;
  };
}
