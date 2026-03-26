final: prev: {
  wezterm = prev.wezterm.overrideAttrs (old: {
    postPatch = builtins.replaceStrings [ "command type -P" ] [ "command -v" ] old.postPatch;
  });
}
