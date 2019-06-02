self: super: {
  Cabal = null;
  hsimport = super.hsimport.overrideAttrs (old: {
    # See https://github.com/NixOS/nixpkgs/pull/42224
    # https://github.com/NixOS/nixpkgs/commit/f8a158c3466
    # Necessary because ghc842 uses an older nixpkgs version
    configureFlags = [ "--libsubdir=$abi/$libname" ];
  });
}
