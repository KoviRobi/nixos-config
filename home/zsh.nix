{ pkgs, lib, ... }:
let nix-prefetch-url = "${pkgs.nix}/bin/nix-prefetch-url";
    dircolors = "${pkgs.coreutils}/bin/dircolors";
    dircolors-file = {
      url = https://raw.githubusercontent.com/seebi/dircolors-solarized/e600c465505d23e9731cfdba1e0d9ccef9883fc1/dircolors.256dark;
      sha256 = "13dajr7s6xckhv9z141cxgiavcp17687z9vyd6p7gkxrjqh8vp9i";
    };
    dircolors-output = "$HOME/.cache/dircolors";
    python3 = "${pkgs.python3.withPackages (p: with p; [ matplotlib numpy ])}/bin/python3";
in {
  programs.zsh = {
    enable = true;
    initExtra = ''
      PROMPT_TOP='%F{blue}%l %h %T%f'$'\n%{\r%}'
      PROMPT_NEST_ROOTP='%(4L.+.%(3L.|.%(2L.:.%(L,.,))))%(!.#.$)'
      PROMPT_BRACE_COLOUR=${"'"}''${''${''${IN_NIX_SHELL:-blue}/impure/default}/pure/white}'
      PROMPT_OPEN='%B%(!.%F{red}[ .%F{${"'"}''${PROMPT_BRACE_COLOUR}'}[[ %f%F{green})'
      PROMPT_CLOSE='%24<... <%(!. %4~%<<. : %f%F{${"'"}''${PROMPT_BRACE_COLOUR}'}%3~%<< ]])'
      PROMPT=''${PROMPT_TOP}''${PROMPT_OPEN}'%n@%m${"'"}''${PROMPT_CLOSE}''${PROMPT_NEST_ROOTP}' %f%b'
      PROMPT2='%B%(!.%F{red}[.%F{blue}[[ %f%F{green})%17<...<%_%<<%(!.. %f%F{blue}>)>%(!.#.$) %f%b'
      RPROMPT='%(1j.%F{yellow}Jobs: %j %f.)%(?..%B%F{red}ERROR: %? `${python3} -c "import os; print(os.strerror($?))"`%b%f)'

      BROWSER="links -g"
      EDITOR="nvim"
      PAGER="less"
      LESS="-iRq"

      alias ls='ls --color'
      alias ll='ls -l --color'
      alias less='less -iRq'
      alias mnt='udisksctl mount -b'
      alias umnt='udisksctl unmount -b'
      alias nixinstall='nix-env -f "<nixpkgs>" -i'
      alias nixrepl='nix repl "<nixpkgs>" "<nixpkgs/nixos>"'
      alias nixpath='nix eval --raw'
      alias vi='nvim'
      alias vim='nvim'
      alias poly='rlwrap poly'
      alias e=$EDITOR
      alias termbin='nc termbin.com 9999'

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

      if [ -e "${dircolors-output}" ]; then
        source "${dircolors-output}"
      else
        declare -a url_file=($(${nix-prefetch-url} ${dircolors-file.url}))
        if [ "''${url_file[1]}" = "${dircolors-file.sha256}" ]; then
          ${dircolors} ''${url_file[2]} > "${dircolors-output}"
        else
          echo "Mismatch for ${dircolors-file.url}, " \
            "got ''${url_file[1]}, " \
            "expected ${dircolors-file.sha256}"
        fi
      fi
    '';
  };
}
