{ pkgs, config, ... }:
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
  yq-go
  xq-xml
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
  nix-tree
  nix-du
  nix-output-monitor
  nil
  nom-rebuild

  dconf
  xxd
  rclone
  (pass.withExtensions (exts: with exts; [ pass-otp ]))
  picocom
  stm32flash
  wally-cli # for flashing ergodox firmware

  plan9port
  acme-lsp
  acre

  _9pfs
  ntfs3g

  gcc
  binutils
  gdb
  radare2
  gnumake
  cmake
  neocmakelsp
  ninja

  devenv

  (python3.withPackages (p: with p; [ matplotlib numpy pandas ply ]))
  pyright
  evcxr
  rustc
  go
  gopls
  sccache
  mold

  atop

  qrencode

  unipicker
  fzf

  ethtool
  wireguard-tools

  kakoune
  helix

  inotify-tools

  zsh-manydots-magic

  entr
] ++
lib.optionals (pkgs.buildPlatform == pkgs.hostPlatform) [
  emacs
  gitFull
  git-absorb
  git-review
  git-filter-repo
] ++
lib.optionals (pkgs.buildPlatform != pkgs.hostPlatform) [
  vim
  git
] ++
lib.optionals (pkgs.hostPlatform.isLinux) [
  config.boot.kernelPackages.cpupower
  abcde
  linuxConsoleTools
  lm_sensors
  nfs-utils
  usbutils
  xfsprogs
]
