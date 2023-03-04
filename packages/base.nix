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
  pciutils
  unzip
  zip
  graphviz
  dos2unix

  man-pages

  nix-prefetch-git
  nix-prefetch-github
  nix-prefetch
  nixpkgs-fmt
  rnix-lsp
  nix-tree
  nix-index
  nix-output-monitor

  dconf
  plan9port
  xxd
  upterm
  youtube-dl
  rclone
  pass
  picocom
  stm32flash
  stlink
  wally-cli # for flashing ergodox firmware

  _9pfs
  ntfs3g

  gdb

  python312
  evcxr
  rustc
  sccache
  mold

  atop

  qrencode

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
  git-absorb
] ++
lib.optionals (pkgs.buildPlatform != pkgs.hostPlatform) [
  vim
  git
] ++
lib.optionals (pkgs.hostPlatform.isLinux) [
  abcde
  linuxConsoleTools
  lm_sensors
  nfs-utils
  usbutils
  xfsprogs
]
