{ pkgs, config, inputs, ... }:
with pkgs;
[
  bashInteractive
  tmux

  inputs.zmx.packages.${pkgs.system}.zmx
  (pkgs.writeShellScriptBin "zms" ''
    zmx-select() {
      local display
      display=$(${inputs.zmx.packages.${pkgs.system}.zmx}/bin/zmx list 2>/dev/null | \
          while IFS=$'\t' read -r name pid clients created dir; do
        name=''${name#*name=}
        pid=''${pid#pid=}
        clients=''${clients#clients=}
        dir=''${dir#started_in=}
        printf "%-20s  pid:%-8s  clients:%-2s  %s\n" "$name" "$pid" "$clients" "$dir"
      done)

      local output query key selected name
      output=$({ [[ -n "$display" ]] && echo "$display"; } | ${pkgs.fzf}/bin/fzf \
        --print-query \
        --expect=ctrl-n \
        --height=80% \
        --reverse \
        --prompt="zmx> " \
        --header="Enter: select | Ctrl-N: create new" \
        --preview='${inputs.zmx.packages.${pkgs.system}.zmx}/bin/zmx history {1}' \
        --preview-window=right:60%:follow \
      )
      local rc=$?

      query=$(echo "$output" | sed -n '1p')
      key=$(echo "$output" | sed -n '2p')
      selected=$(echo "$output" | sed -n '3p')

      if [[ "$key" == "ctrl-n" && -n "$query" ]]; then
        name="$query"
      elif [[ $rc -eq 0 && -n "$selected" ]]; then
        name=$(echo "$selected" | awk '{print $1}')
      elif [[ -n "$query" ]]; then
        name="$query"
      else
        return 130
      fi

      exec ${inputs.zmx.packages.${pkgs.system}.zmx}/bin/zmx attach "$name"
    }

    zmx-select
  '')

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
  acme-lsp

  _9pfs
  ntfs3g

  gcc
  binutils
  gdb
  radare2
  gnumake
  cmake
  ninja

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
