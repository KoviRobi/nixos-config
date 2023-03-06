{ pkgs, lib, config, ... }:
{
  imports = [ ./starship.nix ];

  home.packages = with pkgs; [
    thefuck
    zoxide
  ] ++ lib.optionals (pkgs.buildPlatform == pkgs.hostPlatform) [
    carapace
  ];

  home.sessionVariables = {
    BROWSER = "links -g";
    EDITOR = "nvim";
    PAGER = "less";
    LESS = "-iRq -j5 --mouse --wheel-lines=3 --redraw-on-quit";
    LESSOPEN = "|${pkgs.lesspipe}/bin/lesspipe.sh %s";
    GS_OPTIONS = "-sPAPERSIZE=a4";
  };

  programs.nushell =
    {
      enable = true;
      extraEnv = ''
        ${pkgs.zoxide}/bin/zoxide init nushell | save --force ${config.xdg.configHome}/nushell/zoxide.nu
      '';
      extraConfig = ''
        ${let
            inherit (builtins) readDir readFile mapAttrs attrValues filter
                    match sort lessThan concatStringsSep;
            dir = ./nu;
            dir_files = readDir dir;
            name_type = attrValues (mapAttrs (name: type: { inherit name type; }) dir_files);
            nu_name_type = filter (nt: nt.type == "regular" && match ".*\.nu" nt.name != null) name_type;
            files = map (nt: nt.name) nu_name_type;
            sorted_files = sort lessThan files;
            contents = map (name: readFile (dir + "/${name}")) sorted_files;
          in concatStringsSep "\n" contents}

        use ${pkgs.nu_scripts}/themes/themes/solarized-light.nu *
        use ${pkgs.nu_scripts}/themes/themes/solarized-dark.nu *
        let-env config = ($env.config | update color_config (solarized_light))

        use ${pkgs.nu_scripts}/git/git.nu *
        use ${pkgs.nu_scripts}/custom-completions/git/git-completions.nu *
        use ${pkgs.nu_scripts}/custom-completions/nix/nix-completions.nu *
        use ${pkgs.nu_scripts}/custom-completions/tealdeer/tldr-completions.nu *
        source ${pkgs.nu_scripts}/custom-completions/auto-generate/parse-fish.nu
        use ${pkgs.nu_scripts}/cool-oneliners/cargo_search.nu *
        source ${config.xdg.configHome}/nushell/zoxide.nu
        source "${config.xdg.configHome}/nushell/user-config.nu"

        alias shell = (hide g; g)
        alias g = git
        alias gpf = git push --force-with-lease
        alias grp = git reset -p
        alias gprev = git reset HEAD^
        alias gpprev = git reset -p HEAD^
        alias nixrepl = nix repl --expr 'builtins.getFlake "nixos-config"';
        alias ll = ls -l
        alias la = ls -la
        alias n = ${pkgs.nix}/bin/nix
        alias nf = ${pkgs.nix}/bin/nix flake
        alias nb = ${pkgs.nix-output-monitor}/bin/nom build
        alias der = direnv reload
        alias ded = direnv edit
        alias termbin = nc termbin.com 9999

        # parses a input string in --help format and returns a table of parsed flags
        def parse-help [] {
            # help format  '        -s,                      --long                   <format>                 description   '
            $in | parse -r '\s\s+(?:-(?P<short>\w)[,\s]+)?(?:--(?P<long>[\w-]+))\s*(?:<(?P<format>.*)>)?\s*(?P<description>.*)?'
        }

        # takes a table of parsed help commands in format [short? long format? description]
        def make-completion [command_name: string] {
          "extern \"" + $command_name + "\" [\n" + ($in | each { |it|
              "\t--" + $it.long + (if ($it.short | is-empty) == false {
                  "(-" + $it.short + ")"
                } else {
                  ""
                }) + (if ($it.description | is-empty) == false {
                  "\t\t# " + $it.description
                } else {
                  ""
                })
              } | str join "\n") + "\n\t...args\n]"
        }
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
