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
  gitFull
  tree
  nfs-utils
  pciutils
  usbutils
  lm_sensors
  unzip
  graphviz
  nix-prefetch-git
  nix-prefetch-github
  nixpkgs-fmt
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

  #   From overlays, see nixpkgs.overlays
  emacs
  neovim
  (linkFarm "nvim-vi-vim-alias" [
    { name = "bin/vi"; path = "${neovim}/bin/nvim"; }
    { name = "bin/vim"; path = "${neovim}/bin/nvim"; }
  ]
  )
]
