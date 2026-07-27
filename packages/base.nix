{ pkgs, config, inputs, ... }:
with pkgs;
[
  bashInteractive
  tmux

  zmx
  osc7
  osc7-spawn
  zms
  zmssh
  zmshosts

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
  p7zip
  graphviz
  dos2unix
  audit
  parted

  man-pages
  stdman
  (stdmanpages.overrideAttrs (old: { meta = old.meta // { priority = 9; }; }))

  nix-prefetch-git
  nix-prefetch-github
  nix-prefetch
  nixpkgs-fmt
  nixfmt
  nix-tree
  nix-diff
  nix-du
  nix-output-monitor
  nil
  devenv

  dconf
  xxd
  rclone
  (pass.withExtensions (exts: with exts; [ pass-otp ]))
  picocom
  stm32flash
  wally-cli # for flashing ergodox firmware

  plan9port

  ntfs3g

  gcc
  binutils
  patchelf
  gdb
  dtc
  radare2
  gnumake
  cmake
  ninja

  devenv

  (python3.withPackages (
    p: with p; [
      matplotlib
      numpy
      pandas
      ply
      pyelftools
      requests
      xlrd
    ]
  ))
  pyc
  black
  isort
  evcxr
  rustc
  go
  sccache
  mold

  # Frequently used misc languages
  lua
  tcl
  tk
  # Plus unbuffer on its own is just useful (e.g. coloured pipes)
  expect

  atop

  qrencode
  zbar

  unipicker
  fzf

  ethtool
  wireguard-tools

  kakoune
  editorconfig-core-c
  kakoune-lsp
  kakman
  helix
  ((nnn.override { withNerdIcons = true; }).overrideAttrs (old: {
    postInstall = old.postInstall or "" + ''
        BLK="02"    CHR="03"
        DIR="04"    EXE="01"
        REG="00"    LNK="06"
        SYM="05"    MIS="01"
        ORPHAN="09" FIFO="0D"
        SOCK="0E"   OTHER="0F"
        wrapProgram $out/bin/nnn \
          --set-default NNN_COLORS 4562 \
          --set-default NNN_FCOLORS "$BLK$CHR$DIR$EXE$REG$LNK$SYM$MIS$ORPHAN$FIFO$SOCK$OTHER"
      '';
    }))

  inotify-tools

  zsh-manydots-magic

  entr
]
++ lib.optionals (pkgs.stdenv.buildPlatform == pkgs.stdenv.hostPlatform) [
  (config.programs.git.package or gitFull)
  git-absorb
  git-review
  git-filter-repo
  git-lfs
]
++ lib.optionals (pkgs.stdenv.buildPlatform != pkgs.stdenv.hostPlatform) [
  vim
  git
]
++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
  abcde
  linuxConsoleTools
  lm_sensors
  nfs-utils
  usbutils
  xfsprogs
]
++ lib.optional (config ? "boot") config.boot.kernelPackages.cpupower
