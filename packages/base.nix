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
  audit

  man-pages
  stdman
  stdmanpages

  nix-prefetch-git
  nix-prefetch-github
  nix-prefetch
  nixpkgs-fmt
  nixfmt-rfc-style
  nix-tree
  nix-diff
  nix-du
  nix-output-monitor
  nil
  nom-rebuild
  devenv

  dconf
  xxd
  rclone
  (pass.withExtensions (exts: with exts; [ pass-otp ]))
  picocom
  stm32flash
  wally-cli # for flashing ergodox firmware

  plan9port
  acme-lsp

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
  ccls

  devenv

  (python3.withPackages (
    p: with p; [
      pyelftools
      matplotlib
      numpy
      pandas
      ply
      requests
    ]
  ))
  pyc
  pyright
  black
  isort
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

  busybox # Has low priority by default :)
]
++ lib.optionals (pkgs.buildPlatform == pkgs.hostPlatform) [
  (config.programs.git.package or gitFull)
  git-absorb
  git-review
  git-filter-repo
]
++ lib.optionals (pkgs.buildPlatform != pkgs.hostPlatform) [
  vim
  git
]
++ lib.optionals pkgs.hostPlatform.isLinux [
  abcde
  linuxConsoleTools
  lm_sensors
  nfs-utils
  usbutils
  xfsprogs
]
++ lib.optional (config ? "boot") config.boot.kernelPackages.cpupower
