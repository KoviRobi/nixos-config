{ pkgs, lib, config, ... }:
let
  python3 = "${pkgs.python3.withPackages (p: with p; [ matplotlib numpy ])}/bin/python3";
in
{
  imports = [ ./starship.nix ];

  home.packages = with pkgs; [ thefuck ];

  home.sessionVariables = {
    BROWSER = "links -g";
    EDITOR = "nvim";
    PAGER = "less";
    LESS = "-iRq -j5 --mouse --wheel-lines=3 --redraw-on-quit";
    LESSOPEN = "|${pkgs.lesspipe}/bin/lesspipe.sh %s";
    GS_OPTIONS = "-sPAPERSIZE=a4";
  };

  programs.nushell =
    let
      nu_scripts = pkgs.fetchFromGitHub {
        owner = "nushell";
        repo = "nu_scripts";
        rev = "3334cad9aaad4da6d902645e936e5fbbd8c4cbcf";
        sha256 = "sha256-HuvHMREsyjgMELOWsgWogXs5WI6Ea84rA+W699XbAa8=";
      };
    in
    {
      enable = true;
      extraEnv = ''
        ${pkgs.zoxide}/bin/zoxide init nushell | save --force ${config.xdg.configHome}/nushell/zoxide.nu
      '';
      extraConfig = ''
        source ${config.xdg.configHome}/nushell/zoxide.nu

        use ${nu_scripts}/git/git.nu *
        use ${nu_scripts}/custom-completions/git/git-completions.nu *
        use ${nu_scripts}/custom-completions/nix/nix-completions.nu *
        use ${nu_scripts}/custom-completions/tealdeer/tldr-completions.nu *
        use ${nu_scripts}/ssh/ssh.nu *
        use ${nu_scripts}/cool-oneliners/cargo_search.nu *
        use ${nu_scripts}/themes/themes/solarized-light.nu *

        let-env config = ($env.config | merge {show_banner: false})
        let-env config = ($env.config | merge {color_config: (solarized_light)})
      '';
    };

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

      [ -z "''${terminfo[kcbt]}" ]  || bindkey "''${terminfo[kcbt]}"  reverse-menu-complete
      [ -z "''${terminfo[kdch1]}" ] || bindkey "''${terminfo[kdch1]}" delete-char
      [ -z "''${terminfo[kich1]}" ] || bindkey "''${terminfo[kich1]}" overwrite-mode
      [ -z "''${terminfo[khome]}" ] || bindkey "''${terminfo[khome]}" beginning-of-line
      [ -z "''${terminfo[kend]}" ]  || bindkey "''${terminfo[kend]}"  end-of-line

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
      bindkey "^Q" push-line
      setopt AUTO_PUSHD
      source ${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/history-substring-search/history-substring-search.plugin.zsh
      export HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1
    '';

    enableCompletion = true;
    enableVteIntegration = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;

    shellAliases = {
      "mnt" = "udisksctl mount -b";
      "umnt" = "udisksctl unmount -b";
      "nixinstall" = "nix-env -f '<nixpkgs>' -i";
      "nixeval" = "nix eval -f '<nixpkgs>' --raw";
      "nixpath" = "nix eval --raw";
      "poly" = "rlwrap poly";
      "e" = "\${=EDITOR}";
      "der" = "pushd /; popd";
      "ded" = "direnv edit";
      "dea" = "direnv allow";
      "termbin" = "nc termbin.com 9999";
      "gis" = "git status";
    };
  };
}
