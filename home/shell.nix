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

  programs.starship.enableNushellIntegration = false;
  programs.zoxide.enableNushellIntegration = false;
  programs.direnv.enableNushellIntegration = false;
  programs.nushell =
    {
      enable = true;
      extraConfig = ''
        module aliases {
          ${lib.concatStringsSep "\n  " (lib.mapAttrsToList
            (name: value: ''export alias ${name} = ^${value};'')
            (lib.filterAttrs
              (n: v: !(lib.any (m: n == m) ["ls" "la" "ll"]))
              config.home.shellAliases))}
          export alias ll = ls -l
          export alias la = ls -la
        }
        use aliases *

        use ${./nu}/01-default-completions.nu *
        use ${./nu}/01-default.nu             *
        use ${./nu}/02-rob-default.nu         *
        use ${./nu}/05-nix-support.nu         *
        use ${./nu}/10-maybe-explore.nu       *
        use ${./nu}/20-json-commands.nu       *
        use ${./nu}/30-dir-stack.nu           *

        use ${pkgs.nu_scripts}/themes/themes/solarized-light.nu *
        use ${pkgs.nu_scripts}/themes/themes/solarized-dark.nu *
        $env.config = ($env.config | update color_config (solarized-light))

        use ${pkgs.nu_scripts}/custom-completions/git/git-completions.nu *
        use ${pkgs.nu_scripts}/custom-completions/nix/nix-completions.nu *
        use ${pkgs.nu_scripts}/custom-completions/tealdeer/tldr-completions.nu *
        use ${pkgs.nu_scripts}/cool-oneliners/cargo_search.nu *
        source ${./nu}/zoxide.nu
        source ${./nu}/starship.nu
        source ${./nu}/direnv.nu
        source "${config.xdg.configHome}/nushell/user-config.nu"
      '';
    };

  programs.bash.enable = true;

  programs.zsh = {
    enable = true;
    initExtra = ''
      unsetopt beep
      setopt extendedglob

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
      unsetopt flow_control
      setopt AUTO_PUSHD
      source ${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/history-substring-search/history-substring-search.plugin.zsh
      export HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1

      eval "$(${pkgs.zoxide}/bin/zoxide init zsh | ${pkgs.gnused}/bin/sed 's|\\command zoxide|\\command ${pkgs.zoxide}/bin/zoxide|g')"
    '';

    enableCompletion = true;
    enableVteIntegration = true;
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;
  };
}
