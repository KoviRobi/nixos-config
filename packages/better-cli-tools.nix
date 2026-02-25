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

  zoxide
  delta
  (pkgs.writeShellApplication {
    name = "diff";
    text = ''
      if [ -t 1 ]; then
        ${pkgs.diffutils}/bin/diff "$@" | delta
      else
        ${pkgs.diffutils}/bin/diff "$@"
      fi
    '';
  })
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
  pipe-rename
  scc # Better SLOC measure
  diffoscopeMinimal
  binwalk

  # Markdown
  comrak
  rumdl

  # Python coredump stacktrace
  pystack
  # strace profiling graph generation
  straceprof
]
