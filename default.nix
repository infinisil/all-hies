{}:
let
  legacyError = throw ''
    all-hies has undergone major changes and now needs to be used on a per-project basis.
    See https://github.com/Infinisil/all-hies/blob/master/Readme.md for more info.
    The last version that doesn't have these changes is 4b6aab017cdf96a90641dc287437685675d598da.
  '';
in {
  overlay = import ./overlay.nix;

  combined = legacyError;
  versions = legacyError;
  selection = legacyError;
  latest = legacyError;
  unstable = legacyError;
  bios = legacyError;
  unstableFallback = legacyError;
}
