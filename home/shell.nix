{ pkgs, lib, config, ... }:
{
  imports = [ ./starship.nix ];

  home.packages = with pkgs; [
    thefuck
    zoxide
  ] ++ lib.optionals (pkgs.buildPlatform == pkgs.hostPlatform) [
    carapace
  ];

  programs.bash.initExtra = ''
    eval "$(${pkgs.zoxide}/bin/zoxide init bash | ${pkgs.gnused}/bin/sed 's|\\command zoxide|\\command ${pkgs.zoxide}/bin/zoxide|g')"
  '';

  home.sessionVariables = {
    EDITOR = "nvim";
    PAGER = "less";
    LESS = "-iRq -j5 --mouse --wheel-lines=3 --redraw-on-quit --quit-if-one-screen";
    LESSOPEN = "|${pkgs.lesspipe}/bin/lesspipe.sh %s";
    GS_OPTIONS = "-sPAPERSIZE=a4";
  };

  home.shellAliases = {
    g = "git";
    ga = "git add";
    gap = "git add -p";
    gc = "git commit";
    "gc!" = "git commit --amend";
    gco = "git checkout";
    gd = "git diff";
    gds = "git diff --staged";
    gig = "git update-index --assume-unchanged";
    gp = "git push";
    gpf = "git push --force-with-lease";
    gr = "git remote";
    gre = "git reset";
    greh = "git reset --hard";
    grp = "git reset -p";
    grv = "git remote -v";
    grb = "git rebase";
    gs = "git status";
    gsh = "git show";
    gunig = "git update-index --no-assume-unchanged";

    n = "nix";
    nb = "nom build";
    nepl = "nix repl --expr 'builtins.getFlake \"nixos-config\"'";
    nf = "nix flake";

    dea = "direnv allow";
    ded = "direnv edit";
    der = "direnv reload";

    termbin = "nc termbin.com 9999";

    ls = "${pkgs.eza}/bin/eza";
    ll = "${pkgs.eza}/bin/eza -l";
    la = "${pkgs.eza}/bin/eza -la";

    mnt = "udisksctl mount -b";
    unmnt = "udisksctl unmount -b";
  };

  programs.bash.enable = true;

  programs.zsh = {
    enable = true;
    initExtra = ''
      unsetopt beep

      export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE=fg=white
      export VERSION_CONTROL=numbered


      bindkey -e
      autoload edit-command-line
      zle -N edit-command-line
      bindkey "^X^E" edit-command-line
      bindkey "^P" up-history
      bindkey "^N" down-history
      bindkey "^W" kill-region
      bindkey "^[u" up-case-word
      bindkey "^[l" down-case-word
      bindkey "^Q" push-line
      bindkey "^Z" undo

      [ -z "''${terminfo[kcbt]}" ]  || bindkey "''${terminfo[kcbt]}"  reverse-menu-complete
      [ -z "''${terminfo[kdch1]}" ] || bindkey "''${terminfo[kdch1]}" delete-char
      [ -z "''${terminfo[kich1]}" ] || bindkey "''${terminfo[kich1]}" overwrite-mode
      [ -z "''${terminfo[khome]}" ] || bindkey "''${terminfo[khome]}" beginning-of-line
      [ -z "''${terminfo[kend]}" ]  || bindkey "''${terminfo[kend]}"  end-of-line
      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;5D" backward-word

      # Often I do want to go back to underscores or hyphens
      WORDCHARS=""
      eval $(${pkgs.thefuck}/bin/thefuck --alias fck)


      # The following lines were added by compinstall
      zstyle ':completion:*' completer _complete _ignored
      zstyle ':completion:*' group-name ""
      zstyle ':completion:*' insert-unambiguous true
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
      zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' 'r:|[._-]=** r:|=**'
      zstyle ':completion:*' menu select
      zstyle :compinstall filename '/home/rmk/.zsh.comp'

      autoload -Uz compinit
      compinit
      # End of lines added by compinstall
      compdef _nixos-rebuild nom-rebuild
      unsetopt flow_control
      setopt AUTO_PUSHD
      source ${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/history-substring-search/history-substring-search.plugin.zsh
      export HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1

      eval "$(${pkgs.zoxide}/bin/zoxide init zsh | ${pkgs.gnused}/bin/sed -e 's|\\command zoxide|\\command ${pkgs.zoxide}/bin/zoxide|g' -e '/compdef/d')"

      ${pkgs.fortune}/bin/fortune ${pkgs.apf-cookie}/share/games/fortunes/apf-cookie
    '';

    enableCompletion = true;
    enableVteIntegration = true;
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;
  };
}
