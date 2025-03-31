# From https://dev.to/lissy93/cli-tools-you-cant-live-without-57f6
{ pkgs, ... }:
with pkgs;
[
  dua
  dust
  duf
  hyperfine
  neofetch
  rm-improved

  taskwarrior3
  # Sync taskwarrior to YouTrack/gerrit
  # See https://github.com/GothenburgBitFactory/bugwarrior/issues/1030#issuecomment-2086146053
  # See overlays/mypkgs.nix
  bugwarrior

  zoxide
  delta
  direnv
  starship
  mimi
  fd
  ripgrep
  eza
  lsd
  dnsutils
  bottom
  manix
  skim
  tealdeer
  rlwrap
  pizauth
  dive
]
