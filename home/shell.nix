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

      g     =  "git";
      ga    =  "git add";
      gia   =  ''git add'';
      gCa   =  ''git add $(gCl)'';
      gap   =  "git add -p";
      giA   =  ''git add --patch'';
      giu   =  ''git add --update'';
      gb    =  ''git branch'';
      gba   =  ''git branch --all --verbose'';
      gbL   =  ''git branch --all --verbose'';
      gbd   =  ''git branch --delete'';
      gbx   =  ''git branch --delete'';
      gbD   =  ''git branch --delete --force'';
      gbX   =  ''git branch --delete --force'';
      gbm   =  ''git branch --move'';
      gbr   =  ''git branch --move'';
      gbM   =  ''git branch --move --force'';
      gbR   =  ''git branch --move --force'';
      gbl   =  ''git branch --verbose'';
      gbv   =  ''git branch --verbose'';
      gbV   =  ''git branch --verbose --verbose'';
      gret  =  ''git -c core.editor="$EDITOR \"+:wincmd r|0wincmd w|:0\" -O \"$(git rev-parse --git-dir)/rebase-merge/done\"" rebase --edit-todo'';
      gco   =  "git checkout";
      gbc   =  ''git checkout -b'';
      gCo   =  ''git checkout --ours --'';
      gcO   =  ''git checkout --patch'';
      gCt   =  ''git checkout --theirs --'';
      gcp   =  "git cherry-pick";
      gcpa  =  "git cherry-pick --abort";
      gcpc  =  "git cherry-pick --continue";
      gcP   =  ''git cherry-pick --no-commit'';
      gcY   =  ''git cherry --verbose'';
      gcy   =  ''git cherry --verbose --abbrev'';
      gwc   =  ''git clean --dry-run'';
      gwC   =  ''git clean --force'';
      gfc   =  ''git clone'';
      gfcr  =  ''git clone --recurse-submodules'';
      gc    =  "git commit";
      gcam  =  ''git commit --all --message'';
      "gc!"    = "git commit --amend";
      gcf   =  ''git commit --amend --reuse-message HEAD'';
      gcfS  =  ''git commit --amend --reuse-message HEAD --gpg-sign'';
      gcm   =  ''git commit --message'';
      gcmS  =  ''git commit --message --gpg-sign'';
      gca   =  ''git commit --verbose --all'';
      gcaS  =  ''git commit --verbose --all --gpg-sign'';
      gcF   =  ''git commit --verbose --amend'';
      gcFS  =  ''git commit --verbose --amend --gpg-sign'';
      gcS   =  ''git commit --verbose --gpg-sign'';
      gd    =  "git diff";
      gwd   =  ''git diff --no-ext-diff'';
      gid   =  ''git diff --no-ext-diff --cached'';
      giD   =  ''git diff --no-ext-diff --cached --word-diff'';
      gwD   =  ''git diff --no-ext-diff --word-diff'';
      gds   =  "git diff --staged";
      gf    =  ''git fetch'';
      gfa   =  ''git fetch --all'';
      gFb   =  ''git flow bugfix'';
      gFbc  =  ''git flow bugfix checkout'';
      gFbx  =  ''git flow bugfix delete'';
      gFbd  =  ''git flow bugfix diff'';
      gFbf  =  ''git flow bugfix finish'';
      gFbl  =  ''git flow bugfix list'';
      gFbp  =  ''git flow bugfix publish'';
      gFbm  =  ''git flow bugfix pull'';
      gFbr  =  ''git flow bugfix rebase'';
      gFbs  =  ''git flow bugfix start'';
      gFbt  =  ''git flow bugfix track'';
      gFf   =  ''git flow feature'';
      gFfc  =  ''git flow feature checkout'';
      gFfx  =  ''git flow feature delete'';
      gFfd  =  ''git flow feature diff'';
      gFff  =  ''git flow feature finish'';
      gFfl  =  ''git flow feature list'';
      gFfp  =  ''git flow feature publish'';
      gFfm  =  ''git flow feature pull'';
      gFfr  =  ''git flow feature rebase'';
      gFfs  =  ''git flow feature start'';
      gFft  =  ''git flow feature track'';
      gFh   =  ''git flow hotfix'';
      gFhc  =  ''git flow hotfix checkout'';
      gFhx  =  ''git flow hotfix delete'';
      gFhd  =  ''git flow hotfix diff'';
      gFhf  =  ''git flow hotfix finish'';
      gFhl  =  ''git flow hotfix list'';
      gFhp  =  ''git flow hotfix publish'';
      gFhm  =  ''git flow hotfix pull'';
      gFhr  =  ''git flow hotfix rebase'';
      gFhs  =  ''git flow hotfix start'';
      gFht  =  ''git flow hotfix track'';
      gFi   =  ''git flow init'';
      gFl   =  ''git flow release'';
      gFlc  =  ''git flow release checkout'';
      gFlx  =  ''git flow release delete'';
      gFld  =  ''git flow release diff'';
      gFlf  =  ''git flow release finish'';
      gFll  =  ''git flow release list'';
      gFlp  =  ''git flow release publish'';
      gFlm  =  ''git flow release pull'';
      gFlr  =  ''git flow release rebase'';
      gFls  =  ''git flow release start'';
      gFlt  =  ''git flow release track'';
      gFs   =  ''git flow support'';
      gFsc  =  ''git flow support checkout'';
      gFsx  =  ''git flow support delete'';
      gFsd  =  ''git flow support diff'';
      gFsf  =  ''git flow support finish'';
      gFsl  =  ''git flow support list'';
      gFsp  =  ''git flow support publish'';
      gFsm  =  ''git flow support pull'';
      gFsr  =  ''git flow support rebase'';
      gFss  =  ''git flow support start'';
      gFst  =  ''git flow support track'';
      gg    =  ''git grep'';
      ggl   =  ''git grep --files-with-matches'';
      ggL   =  ''git grep --files-without-matches'';
      ggi   =  ''git grep --ignore-case'';
      ggv   =  ''git grep --invert-match'';
      ggw   =  ''git grep --word-regexp'';
      glS   =  ''git log --show-signature'';
      glg   =  ''git log --topo-order --graph --pretty=format:"$_git_log_oneline_format"'';
      glb   =  ''git log --topo-order --pretty=format:"$_git_log_brief_format"'';
      gl    =  ''git log --topo-order --pretty=format:"$_git_log_medium_format"'';
      glo   =  ''git log --topo-order --pretty=format:"$_git_log_oneline_format"'';
      gld   =  ''git log --topo-order --stat --patch --full-diff --pretty=format:"$_git_log_medium_format"'';
      gls   =  ''git log --topo-order --stat --pretty=format:"$_git_log_medium_format"'';
      gdc   =  ''git ls-files --cached'';
      gdx   =  ''git ls-files --deleted'';
      gdk   =  ''git ls-files --killed'';
      gdm   =  ''git ls-files --modified'';
      gdu   =  ''git ls-files --other --exclude-standard'';
      gm    =  ''git merge'';
      gma   =  "git merge --abort";
      gmc   =  "git merge --continue";
      gmC   =  ''git merge --no-commit'';
      gmF   =  ''git merge --no-ff'';
      gmt   =  ''git mergetool'';
      gCe   =  ''git mergetool $(gCl)'';
      gCl   =  ''git --no-pager diff --name-only --diff-filter=U'';
      gfm   =  ''git pull'';
      gfma  =  ''git pull --autostash'';
      gpp   =  ''git pull origin "$(git-branch-current 2> /dev/null)" && git push origin "$(git-branch-current 2> /dev/null)"'';
      gfr   =  ''git pull --rebase'';
      gfra  =  ''git pull --rebase --autostash'';
      gp    =  "git push";
      gpa   =  ''git push --all'';
      gpA   =  ''git push --all && git push --tags'';
      gpF   =  ''git push --force'';
      gpf   =  "git push --force-with-lease";
      gpc   =  ''git push --set-upstream origin "$(git-branch-current 2> /dev/null)"'';
      gpt   =  ''git push --tags'';
      grb   =  "git rebase";
      gra   =  ''git rebase --abort'';
      grc   =  ''git rebase --continue'';
      gri   =  ''git rebase --interactive'';
      grs   =  ''git rebase --skip'';
      gr    =  "git remote";
      gR    =  ''git remote'';
      gRa   =  ''git remote add'';
      gRp   =  ''git remote prune'';
      gRm   =  ''git remote rename'';
      gRx   =  ''git remote rm'';
      gRs   =  ''git remote show'';
      gRu   =  ''git remote update'';
      grv   =  "git remote -v";
      gRl   =  ''git remote --verbose'';
      gre   =  "git reset";
      gir   =  ''git reset'';
      greh  =  "git reset --hard";
      gwR   =  ''git reset --hard'';
      gcR   =  ''git reset "HEAD^"'';
      grp   =  "git reset -p";
      giR   =  ''git reset --patch'';
      gwr   =  ''git reset --soft'';
      gcr   =  ''git revert'';
      gwx   =  ''git rm -r'';
      gix   =  ''git rm -r --cached'';
      gwX   =  ''git rm -r --force'';
      giX   =  ''git rm -r --force --cached'';
      glc   =  ''git shortlog --summary --numbered'';
      gsh   =  "git show";
      gcs   =  ''git show'';
      gbs   =  ''git show-branch'';
      gbS   =  ''git show-branch --all'';
      gcsS  =  ''git show --pretty=short --show-signature'';
      gsa   =  ''git stash apply'';
      gsx   =  ''git stash drop'';
      gsl   =  ''git stash list'';
      gsp   =  ''git stash pop'';
      gss   =  ''git stash save --include-untracked'';
      gsw   =  ''git stash save --include-untracked --keep-index'';
      gsS   =  ''git stash save --patch --no-keep-index'';
      gsd   =  ''git stash show --patch --stat'';
      gs    =  "git status";
      gwS   =  ''git status --ignore-submodules=$_git_status_ignore_submodules'';
      gws   =  ''git status --ignore-submodules=$_git_status_ignore_submodules --short'';
      gdi   =  ''git status --porcelain --short --ignored | sed -n "s/^!! //p"'';
      gsu   =  "git submodule";
      gS    =  ''git submodule'';
      gSa   =  ''git submodule add'';
      gsud  =  "git submodule deinit";
      gSf   =  ''git submodule foreach'';
      gSi   =  ''git submodule init'';
      gSl   =  ''git submodule status'';
      gSs   =  ''git submodule sync'';
      gsui  =  "git submodule update --init";
      gsuir =  "git submodule update --init --recursive";
      gSI   =  ''git submodule update --init --recursive'';
      gSu   =  ''git submodule update --remote --recursive'';
      gt    =  ''git tag'';
      gtl   =  ''git tag --list'';
      gts   =  ''git tag --sign'';
      gig   =  "git update-index --assume-unchanged";
      gii   =  ''git update-index --assume-unchanged'';
      gunig =  "git update-index --no-assume-unchanged";
      giI   =  ''git update-index --no-assume-unchanged'';
      gtv   =  ''git verify-tag'';

      man = "kakman";
      e = "$EDITOR";

      n = "nix";
      np = "n profile";
      ni = "np install";
      nr = "np remove";
      ns = "n search --no-update-lock-file";
      nb = "nom build";
      nf = "n flake";
      nepl = ''nix repl --expr "let flake = builtins.getFlake \"nixos-config\"; in { inherit flake; } // flake.nixosConfigurations.${config.nixos.hostName}"'';

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
