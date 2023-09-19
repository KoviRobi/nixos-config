{ pkgs, ... }:
with pkgs;
[
  bashInteractive
  tmux
  hunspell
  hunspellDicts.en-gb-ise
  hyphen
  mythes
  file
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
  nom-rebuild

  dconf
  plan9port
  xxd
  rclone
  (pass.withExtensions (exts: with exts; [ pass-otp ]))
  picocom
  stm32flash
  stlink
  wally-cli # for flashing ergodox firmware

  _9pfs
  ntfs3g

  gdb

  (python311.withPackages (p: with p; [ matplotlib numpy pandas ply ]))
  evcxr
  rustc
  sccache
  mold

  atop

  qrencode

  unipicker
  fzf

  binwalk
  ethtool
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
