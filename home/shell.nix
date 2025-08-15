{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [ ./starship.nix ];

  home = {
    packages =
      with pkgs;
      [
        zoxide
      ]
      ++ lib.optionals (pkgs.buildPlatform == pkgs.hostPlatform) [
        carapace
      ];

    sessionVariables = {
      EDITOR = "kak";
      VISUAL = "kak";
      PAGER = "kak";
      LESS = "-iRqw --use-color --color=W-k -j4 -z-4 --mouse --wheel-lines=3 --redraw-on-quit --quit-if-one-screen";
      LESSOPEN = "|${pkgs.lesspipe}/bin/lesspipe.sh %s";
      GS_OPTIONS = "-sPAPERSIZE=a4";
    };

    shellAliases = {
      # quick cd
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";

      # Also consider prezto aliases at
      #  https://github.com/sorin-ionescu/prezto/blob/master/modules/git/alias.zsh
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
      gret = ''git -c core.editor="$EDITOR \"+:wincmd r|0wincmd w|:0\" -O \"$(git rev-parse --git-dir)/rebase-merge/done\"" rebase --edit-todo'';
      gcp = "git cherry-pick";
      gcpc = "git cherry-pick --continue";
      gcpa = "git cherry-pick --abort";
      gs = "git status";
      gsh = "git show";
      gunig = "git update-index --no-assume-unchanged";
      gsu = "git submodule";
      gsui = "git submodule update --init";
      gsuir = "git submodule update --init --recursive";
      gsud = "git submodule deinit";
      gmc = "git merge --continue";
      gma = "git merge --abort";

      man = "kakman";
      e = "$EDITOR";

      n = "nix";
      np = "n profile";
      ni = "np install";
      nr = "np remove";
      ns = "n search --no-update-lock-file";
      nb = "nom build";
      nf = "n flake";
      nepl = "nix repl --expr 'builtins.getFlake \"nixos-config\"'";

      dea = "direnv allow";
      ded = "direnv edit";
      der = "direnv reload";

      termbin = "nc termbin.com 9999";

      ls = "${pkgs.eza}/bin/eza";
      ll = "${pkgs.eza}/bin/eza -l";
      la = "${pkgs.eza}/bin/eza -la";

      mnt = "udisksctl mount -b";
      unmnt = "udisksctl unmount -b";

      # internet ip
      myip = "dig +short myip.opendns.com @208.67.222.222 2>&1";

      ctl = "systemctl";
      stl = "sudo systemctl";
      utl = "systemctl --user";
      us = "systemctl --user status";
      ut = "systemctl --user start";
      un = "systemctl --user stop";
      ss = "systemctl status";
      up = "sudo systemctl start";
      dn = "sudo systemctl stop";
      jtl = "journalctl";
    };
  };

  programs = {
    bash = {
      enable = true;
      initExtra = ''
        eval "$(${pkgs.zoxide}/bin/zoxide init bash | ${pkgs.gnused}/bin/sed 's|\\command zoxide|\\command ${pkgs.zoxide}/bin/zoxide|g')"

        if [ -e "$HOME/.bashrc.local" ]; then
          source "$HOME/.bashrc.local"
        fi
      '';
    };

    zsh = {
      enable = true;
      # Disable prezto fortune
      loginExtra = ''
        fortune() { :; }
      '';
      profileExtra = builtins.concatStringsSep "" (
        builtins.attrValues (
          builtins.mapAttrs (name: value: ''
            export ${name}="${toString value}"
          '') config.home.sessionVariables
        )
      );
      prezto = {
        enable = true;
        autosuggestions.color = "fg=yellow";
        editor.dotExpansion = true;
        utility.safeOps = false;
        pmodules = [
          "environment"
          "terminal"
          "editor"
          "history"
          "git"
          "syntax-highlighting"
          "autosuggestions"
          "directory"
          "spectrum"
          "utility"
          "history-substring-search"
          "completion"
        ];
        caseSensitive = false;
      };
      initContent = ''
        unsetopt beep

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


        compdef _nixos-rebuild nom-rebuild
        compdef _man viman
        compdef _man kakman
        # No man-page sections for viman
        eval "$(zstyle -L '*' insert-sections | sed 's/^zstyle/& -d/')"
        zstyle ':completion:*:manuals*' insert-sections suffix
        zle -C complete-file complete-word _generic
        zstyle ':completion:complete-file::::' completer _file
        bindkey '^X^F' complete-file
        unsetopt flow_control
        unsetopt PATH_DIRS
        setopt AUTO_PUSHD

        function _semprompt_cmd_start() {
          builtin print -n '\e]133;C\e\\'
        }
        function _semprompt_cmd_end() {
          builtin printf '\e]133;D;%d\e\\' "$?"
        }

        add-zsh-hook preexec _semprompt_cmd_start
        # precmd is badly named -- it is in fact pre-prompt, post CMD
        add-zsh-hook precmd  _semprompt_cmd_end

        eval "$(${pkgs.zoxide}/bin/zoxide init zsh | ${pkgs.gnused}/bin/sed -e 's|\\command zoxide|\\command ${pkgs.zoxide}/bin/zoxide|g' -e '/compdef/d')"

        ${pkgs.fortune}/bin/fortune ${pkgs.apf-cookie}/share/games/fortunes/apf-cookie

        if [ -e "$HOME/.zshrc.local" ]; then
          source "$HOME/.zshrc.local"
        fi
      '';
    };
  };
}
