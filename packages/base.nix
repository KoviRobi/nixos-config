{ pkgs, ... }:
with pkgs;
[
  wget
  tmux
  ispell
  file
  netcat
  socat
  lsof
  gnupg
  clamav
  krb5
  pv
  jq
  tree
  nfs-utils
  pciutils
  usbutils
  lm_sensors
  unzip
  graphviz

  abcde

  man-pages

  nix-prefetch-git
  nix-prefetch-github
  nixpkgs-fmt
  rnix-lsp
  nix-tree
  nix-index

  dconf
  plan9port
  xxd
  upterm
  youtube-dl
  rclone
  pass
  linuxConsoleTools
  picocom
  stm32flash
  stlink
  wally-cli # for flashing ergodox firmware

  _9pfs
  ntfs3g
  xfsprogs

  gdb

  #   From overlays, see nixpkgs.overlays
] ++
lib.optionals (pkgs.buildPlatform == pkgs.hostPlatform) [
  emacs
  neovim
  (linkFarm "nvim-vi-vim-alias" [
    { name = "bin/vi"; path = "${neovim}/bin/nvim"; }
    { name = "bin/vim"; path = "${neovim}/bin/nvim"; }
  ])
  gitFull
] ++
lib.optionals (pkgs.buildPlatform != pkgs.hostPlatform) [
  vim
  git
]
