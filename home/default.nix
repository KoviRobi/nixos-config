{ pkgs, lib, ... }:

let xclip = "${pkgs.xclip}/bin/xclip";
    dircolors = "${pkgs.coreutils}/bin/dircolors";
    i3 = "${pkgs.i3}";
    i3lock = "${pkgs.i3lock}/bin/i3lock";
    xcape = "${pkgs.xcape}/bin/xcape";
    maxima = "${pkgs.maxima}/bin/maxima";
    python3 = "${pkgs.python3.withPackages (p: with p; [ matplotlib numpy ])}/bin/python3";
    guile = "${pkgs.guile}/bin/guile";
    zsh = "${pkgs.zsh}/bin/zsh";
    emacs = "${pkgs.myEmacs}/bin/emacs";
in
{
  home.packages = [
    pkgs.htop
    pkgs.fortune
  ];

  programs.tmux = {
    enable = true;
    aggressiveResize = true;
    escapeTime = 0;
    terminal = "screen-256color";
    clock24 = true;
    plugins = with pkgs.tmuxPlugins; [ copycat tmux-colors-solarized
      prefix-highlight sidebar urlview yank fpp ];
    extraConfig = ''
      set -g renumber-windows on
      set -g mouse on
      set -g set-titles on
      set -g alternate-screen off

      bind-key C new-window -c "#{pane_current_path}"

      # Tmux and I disagree on what is horizontal and what is vertical
      # I take the view that Vim does
      bind-key v if-shell "${i3}/bin/i3-msg split horizontal" \
          "run-shell -b \"xterm -e tmux new-session -t #{session_group} '\;' new-window\"" \
          "split-window -h"
      bind-key V if-shell "${i3}/bin/i3-msg split horizontal" \
          "run-shell -b \"xterm -e tmux new-session -t #{session_group} '\;' new-window -c #{pane_current_path}\""  \
          "split-window -h -c #{pane_current_path}"
      bind-key h if-shell "${i3}/bin/i3-msg split vertical" \
          "run-shell -b \"xterm -e tmux new-session -t #{session_group} '\;' new-window\"" \
          "split-window -v"
      bind-key H if-shell "${i3}/bin/i3-msg split vertical" \
          "run-shell -b \"xterm -e tmux new-session -t #{session_group} '\;' new-window -c #{pane_current_path}\"" \
          "split-window -v -c #{pane_current_path}"
      bind-key -T root C-PageUp copy-mode -eu

      bind-key s capture-pane -e -b screenshot_raw\;\
          capture-pane -b screenshot_plain\;\
          save-buffer -b screenshot_raw 'tmux_screenshot_raw'\;\
          save-buffer -b screenshot_plain 'tmux_screenshot_plain'
      bind-key S capture-pane -e -S - -E - -b screenshot_raw\;\
          capture-pane -S - -E - -b screenshot_plain\;\
          save-buffer -b screenshot_raw 'tmux_screenshot_raw'\;\
          save-buffer -b screenshot_plain 'tmux_screenshot_plain'

      bind-key -T copy-mode    WheelUpPane   send-keys -X scroll-up
      bind-key -T copy-mode    WheelDownPane send-keys -X scroll-down
      bind-key -T copy-mode-vi WheelUpPane   send-keys -X scroll-up
      bind-key -T copy-mode-vi WheelDownPane send-keys -X scroll-down

      bind-key -T copy-mode    C-PageUp      send-keys -X page-up
      bind-key -T copy-mode-vi C-PageUp      send-keys -X page-up
      bind-key -T copy-mode    C-PageDown    send-keys -X page-down
      bind-key -T copy-mode-vi C-PageDown    send-keys -X page-down

      bind-key -T copy-mode    MouseDragEnd1Pane  send-keys -X copy-pipe "${xclip} -i -selection primary"
      bind-key -T copy-mode-vi MouseDragEnd1Pane  send-keys -X copy-pipe "${xclip} -i -selection primary"
    '';
  };

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

      ${let dircolors-file = builtins.fetchurl {
            url = https://raw.githubusercontent.com/seebi/dircolors-solarized/master/dircolors.256dark;
            sha256 = "051py3g56vyzy44j32hajcq02g8rn9v3k3amccpqjaacyibxqxzb";
          };
          dircolors-output = pkgs.runCommandNoCC ''dircolors-solarized'' {}
            "${dircolors} ${dircolors-file} > $out";
        in builtins.readFile dircolors-output
        }
    '';
  };

  programs.direnv = {
    enable = true;
    stdlib = ''
      # Load environment variables from `nix-shell` and export it out.
      #
      # Usage: use_nix [-s <nix-expression>] [-w <path>] [-w <path>] ...
      #   -s nix-expression: The nix expression to use for building the shell environment.
      #   -w path: watch a file for changes. It can be specified multiple times. The
      #      shell specified with -s is automatically watched.
      #
      #   If no nix-expression were given with -s, it will attempt to find and load
      #   the shell using the following files in order: shell.nix and default.nix.
      #
      # Example:
      #   -  use_nix
      #   -  use_nix -s shell.nix -w .nixpkgs-version.json
      #
      # The dependencies pulled by nix-shell are added to Nix's garbage collector
      # roots, such that the environment remains persistent.
      #
      # Nix-shell is invoked only once per environment, and the output is cached for
      # better performance. If any of the watched files change, then the environment
      # is rebuilt.
      #
      # To remove old environments, and allow the GC to collect their dependencies:
      # rm -f .direnv

      use_nix() {
        # define all local variables
        local shell
        local files_to_watch=()

        local opt OPTARG OPTIND # define vars used by getopts locally
        while getopts ":n:s:w:" opt; do
          case "''${opt}" in
            s)
              shell="''${OPTARG}"
              files_to_watch=("''${files_to_watch[@]}" "''${shell}")
              ;;
            w)
              files_to_watch=("''${files_to_watch[@]}" "''${OPTARG}")
              ;;
            :)
              fail "Invalid option: $OPTARG requires an argument"
              ;;
            \?)
              fail "Invalid option: $OPTARG"
              ;;
          esac
        done
        shift $((OPTIND -1))

        if [[ -z "''${shell}" ]]; then
          if [[ -f shell.nix ]]; then
            shell=shell.nix
            files_to_watch=("''${files_to_watch[@]}" shell.nix)
          elif [[ -f default.nix ]]; then
            shell=default.nix
            files_to_watch=("''${files_to_watch[@]}" default.nix)
          else
            fail "ERR: no shell was given"
          fi
        fi

        local f
        for f in "''${files_to_watch[@]}"; do
          if ! [[ -f "''${f}" ]]; then
            fail "cannot watch file ''${f} because it does not exist"
          fi
        done

        # compute the hash of all the files that makes up the development environment
        local env_hash="$(hash_contents "''${files_to_watch[@]}")"

        # define the paths
        local dir="$(direnv_layout_dir)"
        local wd="''${dir}/wd-''${env_hash}"
        local drv="''${wd}/env.drv"
        local dump="''${wd}/dump.env"

        # Generate the environment if we do not have one generated already.
        if [[ ! -f "''${drv}" ]]; then
          mkdir -p "''${wd}"

          log_status "use nix: deriving new environment"
          IN_NIX_SHELL=1 nix-instantiate --add-root "''${drv}" --indirect "''${shell}" > /dev/null
          nix-store -r $(nix-store --query --references "''${drv}") --add-root "''${wd}/dep" --indirect > /dev/null
          if [[ "''${?}" -ne 0 ]] || [[ ! -f "''${drv}" ]]; then
            rm -rf "''${wd}"
            fail "use nix: was not able to derive the new environment. Please run 'direnv reload' to try again."
          fi

          log_status "use nix: updating cache"
          nix-shell --pure "''${drv}" --show-trace --run "$(join_args "$direnv" dump bash)" > "''${dump}"
          if [[ "''${?}" -ne 0 ]] || [[ ! -f "''${dump}" ]] || ! grep -q IN_NIX_SHELL "''${dump}"; then
            rm -rf "''${wd}"
            fail "use nix: was not able to update the cache of the environment. Please run 'direnv reload' to try again."
          fi
        fi

        for d in ''${dir}/*; do
          if [ "$wd" != "$d" ]; then
            echo "Old direnv working directory: $d"
          fi
        done

        # evaluate the dump created by nix-shell earlier, but have to merge the PATH
        # with the current PATH
        # NOTE: we eval the dump here as opposed to direnv_load it because we don't
        # want to persist environment variables coming from the shell at the time of
        # the dump. See https://github.com/direnv/direnv/issues/405 for context.
        local path_backup="''${PATH}"
        eval $(cat "''${dump}")
        export PATH="''${PATH}:''${path_backup}"

        # cleanup the environment of variables that are not requried, or are causing issues.
        unset shellHook  # when shellHook is present, then any nix-shell'd script will execute it!

        # watch all the files we were asked to watch for the environment
        for f in "''${files_to_watch[@]}"; do
          watch_file "''${f}"
        done
      }

      fail() {
        log_error "''${@}"
        exit 1
      }

      hash_contents() {
          ${pkgs.coreutils}/bin/cat "''${@}" | \
          ${pkgs.coreutils}/bin/sha256sum | \
          ${pkgs.coreutils}/bin/cut -c -64
      }

      hash_file() {
          ${pkgs.coreutils}/bin/sha256sum "''${@}" | \
          ${pkgs.coreutils}/bin/cut -c -64
      }
    '';
  };


  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };

  services.parcellite.enable = true;
  services.pasystray.enable = true;
  services.dunst.enable = true;
  #services.screen-locker = {
  #  enable = true;
  #  lockCmd = ''
  #    killall -SIGUSR1 dunst
  #    {i3lock} -n
  #    killall  -SIGUSR2 dunst
  #  '';
  #};

  services.xcape = {
    enable = true;
    mapExpression = { Shift_L = "parenleft"; Shift_R = "parenright"; };
    timeout = 250;
  };

  programs.git = {
    enable = true;
    userName = "Kovacsics Robert";
    userEmail = "rmk35@cam.ac.uk";
  };

  programs.ssh = {
    controlMaster = "auto";
    controlPath = "~/.ssh/master-%r@%h:%p";
    controlPersist = "10m";
    extraConfig = ''
      Host *.cl.cam.ac.uk ely orfina mawddach
        GSSAPIAuthentication yes
        GSSAPIDelegateCredentials yes

      Host nix-hydra
        HostName caelum-vm-127.cl.cam.ac.uk.
        User rmk35
    '';
  };

  programs.home-manager = {
    enable = true;
  };

  xresources.extraConfig = builtins.readFile (
    pkgs.fetchFromGitHub {
      owner = "solarized";
      repo = "xresources";
      rev = "025ceddbddf55f2eb4ab40b05889148aab9699fc";
      sha256 = "0lxv37gmh38y9d3l8nbnsm1mskcv10g3i83j0kac0a2qmypv1k9f";
    } + "/Xresources.dark");
    xresources.properties = {
      "XTerm.termName" = "xterm-256color";
      "XTerm.backarrowKeyIsErase"   = "true";
      "XTerm.ptyInitialErase"       = "true";
      "XTerm.vt100.metaSendsEscape" = "true";
      "XTerm.vt100.faceSize"        = "9";
      "XTerm.vt100.faceSize1"       = "2";
      "XTerm.vt100.faceSize2"       = "6";
      "XTerm.vt100.faceSize3"       = "8";
      "XTerm.vt100.faceSize4"       = "12";
      "XTerm.vt100.faceSize5"       = "24";
      "XTerm.vt100.faceSize6"       = "72";
      "XTerm.vt100.boldColors"      = "false";
      "XTerm.vt100.faceName"        = "xft:DejaVu Sans Mono for Powerline";
      "XTerm.vt100.boldFont"        = "xft:DejaVu Sans Mono for Powerline:bold";
    };

  xsession.enable = true;
  xsession.windowManager.i3 = {
    enable = true;
    package = i3;
    config = let mod = "Mod4"; in {
      modifier = mod;
      startup = [
        { command = "$HOME/shared-configs/i3/.config/i3/workspace_rename.py"; always = true; notification = false; }
      ];
      window.commands = [
        { command = "move scratchpad"; criteria = { instance = "^scratch_.*$"; }; }
      ];
      keybindings =
        let scratch = n: p: '' \
            exec --no-startup-id xprop -name '${n}' > /dev/null || \
            ${p} ; \
            [instance="^${n}$"] scratchpad show
          '';
          scratch_xterm = n: p: scratch n
            "xterm -name '${n}' -title '${n}' -xrm '*.allowTitleOps: false' -e '${p}'";
        in lib.mkOptionDefault {
          "${mod}+Shift+c" = "kill";
          "${mod}+Return" = "exec xterm -e $HOME/bin/tmux_current_workspace";
          "${mod}+Shift+Return" = "exec xterm";
          "${mod}+p" = "exec $HOME/shared-configs/i3/.config/i3/dmenu_run";
          "${mod}+a" = "exec $HOME/shared-configs/i3/.config/i3/dmenu_action";
          "${mod}+Delete" = "exec $HOME/shared-configs/i3/.config/i3/actions/lock";
          "${mod}+Shift+m" = scratch_xterm "scratch_maxima" "${maxima}";
          "${mod}+Shift+p" = scratch_xterm "scratch_python" "PYTHONSTARTUP=~/.pythonrc.scratch.py ${python3}";
          "${mod}+Shift+g" = scratch_xterm "scratch_guile" "${guile}";
          "${mod}+Shift+s" = scratch_xterm "scratch_shell" "${zsh}";
          "${mod}+Shift+e" = scratch "scratch_emacs" "${emacs} --name scratch_emacs";
          "${mod}+Control+h" = "split v";
          "${mod}+Control+v" = "split h";
          "${mod}+Control+s" = "layout stacking";
          "${mod}+Control+t" = "layout tabbed";
          "${mod}+Control+e" = "layout toggle split";
          "${mod}+w" = "focus parent";
          "${mod}+d" = "focus child";
          "${mod}+t" = "exec $HOME/shared-configs/i3/.config/i3/dmenu_workspace 'workspace'";
          "${mod}+Shift+t" = "exec $HOME/shared-configs/i3/.config/i3/dmenu_workspace 'move container to workspace'";
          "${mod}+Shift+r" = "reload";
          "${mod}+Control+Shift+r" = "restart";
          "${mod}+bracketleft"  = "workspace prev";
          "${mod}+bracketright" = "workspace next";
          "${mod}+Shift+bracketleft"  = "move container to workspace prev";
          "${mod}+Shift+bracketright" = "move container to workspace next";
      };
    };
  };
}
