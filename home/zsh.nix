{ pkgs, lib, ... }:
let
  python3 = "${pkgs.python3.withPackages (p: with p; [ matplotlib numpy ])}/bin/python3";
in
{

  home.packages = with pkgs; [ thefuck ];
  programs.zsh = {
    enable = true;
    initExtra = ''
      autoload -Uz vcs_info
      zstyle ':vcs_info:*' enable git

      zstyle ':vcs_info:*' actionformats '(%b|%a)'
      zstyle ':vcs_info:*' formats       '(%b)'

      precmd_functions+=(vcs_info)

      unsetopt beep
      setopt extendedglob

      export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE=fg=white
      export VERSION_CONTROL=numbered

      BROWSER="links -g"
      EDITOR="nvim"
      PAGER="less"
      LESS="-iRq"

      bindkey -e
      zle -N edit-command-line
      bindkey "^X^E" edit-command-line
      bindkey "^P" up-history
      bindkey "^N" down-history
      bindkey "^W" kill-region
      bindkey "^[u" up-case-word
      bindkey "^[l" down-case-word

      [ -z "''${terminfo[kcbt]}" ]  || bindkey "''${terminfo[kcbt]}"  reverse-menu-complete
      [ -z "''${terminfo[kdch1]}" ] || bindkey "''${terminfo[kdch1]}" delete-char
      [ -z "''${terminfo[kich1]}" ] || bindkey "''${terminfo[kich1]}" overwrite-mode
      [ -z "''${terminfo[khome]}" ] || bindkey "''${terminfo[khome]}" beginning-of-line
      [ -z "''${terminfo[kend]}" ]  || bindkey "''${terminfo[kend]}"  end-of-line

      # Often I do want to go back to underscores or hyphens
      WORDCHARS=""
      # For plan9port
      unalias 9
      eval $(${pkgs.thefuck}/bin/thefuck --alias fck)
    '';

    enableCompletion = true;
    enableVteIntegration = true;
    enableAutosuggestions = true;
    oh-my-zsh.enable = true;

    shellAliases = {
      "ls" = "ls --color";
      "ll" = "ls -l --color";
      "less" = "less -iRq";
      "mnt" = "udisksctl mount -b";
      "umnt" = "udisksctl unmount -b";
      "nixinstall" = "nix-env -f '<nixpkgs>' -i";
      "nixeval" = "nix eval -f '<nixpkgs>' --raw";
      "nixrepl" = "nix repl '<nixpkgs>' '<nixpkgs/nixos>'";
      "nixpath" = "nix eval --raw";
      "poly" = "rlwrap poly";
      "e" = "\${=EDITOR}";
      "der" = "cd /; cd -";
      "ded" = "direnv edit";
      "dea" = "direnv allow";
      "termbin" = "nc termbin.com 9999";
      "gis" = "git status";
    };
  };
}
