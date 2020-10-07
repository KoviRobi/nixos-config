{ pkgs, lib, ... }:
let
  dircolors = "${pkgs.coreutils}/bin/dircolors";
  dircolors-file = builtins.fetchurl {
    url = https://raw.githubusercontent.com/seebi/dircolors-solarized/e600c465505d23e9731cfdba1e0d9ccef9883fc1/dircolors.256dark;
    sha256 = "13dajr7s6xckhv9z141cxgiavcp17687z9vyd6p7gkxrjqh8vp9i";
  };
  dircolors-output = pkgs.runCommandNoCC ''dircolors-solarized''
    { }
    "${dircolors} ${dircolors-file} > $out";
  python3 = "${pkgs.python3.withPackages (p: with p; [ matplotlib numpy ])}/bin/python3";
in
{
  programs.zsh = {
    enable = true;
    initExtra = ''
      autoload -Uz vcs_info
      zstyle ':vcs_info:*' enable git

      zstyle ':vcs_info:*' actionformats '(%b|%a)'
      zstyle ':vcs_info:*' formats       '(%b)'

      precmd_functions+=(vcs_info)

      unsetopt beep

      set -o PROMPT_SUBST
      PROMPT_TOP='%F{blue}%l %h %T ''${vcs_info_msg_0_}%f'$'\n%{\r%}'
      PROMPT_NEST_ROOTP='%(6L.#.%(5L.*.%(4L.+.%(3L.|.%(2L.:.%(L,.,))))))%(!.#.$)'
      PROMPT_BRACE_COLOUR=${"'"}''${''${''${IN_NIX_SHELL:-blue}/impure/default}/pure/white}'
      PROMPT_OPEN='%B%(!.%F{red}[ .%F{${"'"}''${PROMPT_BRACE_COLOUR}'}[[ %f%F{green})'
      PROMPT_CLOSE='%24<... <%(!. %4~%<<. : %f%F{${"'"}''${PROMPT_BRACE_COLOUR}'}%3~%<< ]])'
      PROMPT=''${PROMPT_TOP}''${PROMPT_OPEN}'%n@%m${"'"}''${PROMPT_CLOSE}''${PROMPT_NEST_ROOTP}' %f%b'
      PROMPT2='%B%(!.%F{red}[.%F{blue}[[ %f%F{green})%17<...<%_%<<%(!.. %f%F{blue}>)>%(!.#.$) %f%b'
      RPROMPT='%(1j.%F{yellow}Jobs: %j %f.)%(?..%B%F{red}ERROR: %? `${python3} -c "import os; print(os.strerror($?))"`%b%f)'

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

      [ -z "''${terminfo[kcbt]}" ]  || bindkey "''${terminfo[kcbt]}"  reverse-menu-complete
      [ -z "''${terminfo[kdch1]}" ] || bindkey "''${terminfo[kdch1]}" delete-char
      [ -z "''${terminfo[kich1]}" ] || bindkey "''${terminfo[kich1]}" overwrite-mode
      [ -z "''${terminfo[khome]}" ] || bindkey "''${terminfo[khome]}" beginning-of-line
      [ -z "''${terminfo[kend]}" ]  || bindkey "''${terminfo[kend]}"  end-of-line

      np() {
        echo $NIX_PATH | tr : '\n' | sed -n "s|$1=||p"
      }

      source ${dircolors-output}
    '';

    shellAliases = {
      "ls" = "ls --color";
      "ll" = "ls -l --color";
      "less" = "less -iRq";
      "mnt" = "udisksctl mount -b";
      "umnt" = "udisksctl unmount -b";
      "nixinstall" = "nix-env -f '<nixpkgs>' -i";
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
