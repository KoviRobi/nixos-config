{ pkgs, lib, ... }:
let i3 = "${pkgs.i3}";
    i3lock = "${pkgs.i3lock}/bin/i3lock";
    mod = "Mod4"; # Win key

    scratch = n: p: '' \
      exec --no-startup-id xprop -name '${n}' > /dev/null || \
      ${p} ; \
      [instance="^${n}$"] scratchpad show
    '';
    scratch_xterm = n: p: scratch n
      "xterm -name '${n}' -title '${n}' -xrm '*.allowTitleOps: false' -e '${p}'";
    maxima = "${pkgs.maxima}/bin/maxima";
    python3 = "${pkgs.python3.withPackages (p: with p; [ matplotlib numpy ])}/bin/python3";
    guile = "${pkgs.guile}/bin/guile";
    zsh = "${pkgs.zsh}/bin/zsh";
    emacs = "${pkgs.myEmacs}/bin/emacs";

    i3-helpers = import ./i3-helpers.nix pkgs;
in {
  services.network-manager-applet.enable = true;
  services.parcellite.enable = true;
  services.pasystray.enable = true;
  services.dunst.enable = true;
  home.file.backgrounds = { recursive = true; source = ./backgrounds; };
  services.random-background = { enable = true; imageDirectory = ""; interval = "1h"; };
  systemd.user.services.random-background.Service.ExecStart = lib.mkForce
    "${pkgs.feh}/bin/feh --bg-max --randomize %h/backgrounds";
  services.screen-locker = {
    enable = true;
    lockCmd = ''${i3-helpers.actions.lock}'';
  };
  services.compton = { enable = true; opacityRule =
    [ "87:class_i ?= 'scratchpad'" "91:class_i ?= 'xterm'"
      "0:_NET_WM_STATE@:32a = '_NET_WM_STATE_HIDDEN'"
      "0:_NET_WM_STATE@[0]:32a = '_NET_WM_STATE_HIDDEN'"
      "0:_NET_WM_STATE@[1]:32a = '_NET_WM_STATE_HIDDEN'"
      "0:_NET_WM_STATE@[2]:32a = '_NET_WM_STATE_HIDDEN'"
      "0:_NET_WM_STATE@[3]:32a = '_NET_WM_STATE_HIDDEN'"
      "0:_NET_WM_STATE@[4]:32a = '_NET_WM_STATE_HIDDEN'" ]; };

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
      "XTerm.vt100.faceName"        = "xft:DejaVu Sans Mono";
      "XTerm.vt100.boldFont"        = "xft:DejaVu Sans Mono";
    };

  xsession.enable = true;
  xsession.initExtra = "~/.fehbg || true &";
  xsession.windowManager.i3 = {
    enable = true;
    package = i3;
    config = {
      fonts = [ "DejaVu Sans 9" ];
      bars = [ { fonts = [ "DejaVu Sans 9" ];
        statusCommand = "${pkgs.i3status}/bin/i3status -c ${./i3status-config}";
      } ];
      modifier = mod;
      startup = [
        { command = "${i3-helpers.workspace-renumber}"; always = true; notification = false; }
      ];
      window.commands = [
        { command = "move scratchpad"; criteria = { instance = "^scratch_.*$"; }; }
        { command = "floating enable"; criteria = { window_type = "popup_menu"; }; }
        { command = "border none";     criteria = { window_type = "popup_menu"; }; }
      ];
      keybindings = lib.mkOptionDefault ({
        "${mod}+Shift+c" = "kill";
        "${mod}+Return" = "exec xterm -e ${i3-helpers.tmux-current-workspace}";
        "${mod}+Shift+Return" = "exec xterm";
        "${mod}+p" = "exec ${i3-helpers.dmenu-run}";
        "${mod}+a" = "exec ${i3-helpers.dmenu-action}";
        "${mod}+Delete" = "exec ${i3-helpers.actions.lock}";
        "${mod}+Shift+m" = scratch_xterm "scratch_maxima" "${maxima}";
        "${mod}+Shift+p" = scratch_xterm "scratch_python" "PYTHONSTARTUP=~/.pythonrc.scratch.py ${python3}";
        "${mod}+Shift+g" = scratch_xterm "scratch_guile" "${guile}";
        "${mod}+Shift+s" = scratch_xterm "scratch_shell" "${zsh}";
        "${mod}+Shift+e" = scratch "scratch_emacs" "${emacs} --name scratch_emacs";
        "${mod}+e" =  "exec emacsclient -a '' -c";
        "${mod}+Control+h" = "split v";
        "${mod}+Control+v" = "split h";
        "${mod}+Control+s" = "layout stacking";
        "${mod}+Control+t" = "layout tabbed";
        "${mod}+Control+e" = "layout toggle split";
        "${mod}+w" = "focus parent";
        "${mod}+d" = "focus child";
        "${mod}+t" = "exec ${i3-helpers.dmenu-workspace} 'workspace'";
        "${mod}+Shift+t" = "exec ${i3-helpers.dmenu-workspace} 'move container to workspace'";
        "${mod}+Shift+r" = "reload";
        "${mod}+Control+Shift+r" = "restart";
        "${mod}+bracketleft"  = "workspace prev";
        "${mod}+bracketright" = "workspace next";
        "${mod}+Shift+bracketleft"  = "move container to workspace prev";
        "${mod}+Shift+bracketright" = "move container to workspace next";
      } //
      (builtins.listToAttrs (
        (builtins.genList (n: let m = toString (n+1); in
          { name = "${mod}+${m}";
            value = "exec ${i3-helpers.workspace-action} 'workspace' ${m}"; })
          9) ++
        (builtins.genList (n: let m = toString (n+1); in
          { name = "${mod}+Shift+${m}";
            value = "exec ${i3-helpers.workspace-action} 'move container to workspace' ${m}"; })
          9))));
    };
  };
}
