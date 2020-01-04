{ pkgs, lib, ... }:
let i3 = "${pkgs.i3}";
    i3-helpers = import ./i3-helpers.nix pkgs;
    mod = "Mod4"; # Win key

    maxima = "${pkgs.maxima}/bin/maxima";
    python3 = "${pkgs.python3.withPackages (p: with p; [ matplotlib numpy ])}/bin/python3";
    guile = "${pkgs.guile}/bin/guile";
    zsh = "${pkgs.zsh}/bin/zsh";
    emacs = "${pkgs.emacs}/bin/emacs";

    scratch = n: p: '' \
      exec --no-startup-id xprop -name '${n}' > /dev/null || \
      ${p} ; \
      [instance="^${n}$"] scratchpad show
    '';
    scratch_xterm = n: p: scratch n
      "xterm -name '${n}' -title '${n}' -xrm '*.allowTitleOps: false' -e '${p}'";
in {
  xsession.windowManager.i3 = {
    enable = true;
    package = i3;
    config = {
      fonts = [ "Latin Modern Roman,Regular 9" ];
      bars = [ { fonts = [ "Latin Modern Roman,Regular 9" ]; statusCommand =
        "${pkgs.i3status}/bin/i3status -c ${import ./i3status-config.nix pkgs}";
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
        "${mod}+e" =  ''exec emacsclient -a "" -c'';
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
        "--whole-window ${mod}+button2" = "exec ${i3-helpers.pen-pye-menu}/bin/general_menu";
        "--release button2" = "exec ${i3-helpers.pen-pye-menu}/bin/window_menu";
        "XF86AudioMute" = "exec ${i3-helpers.actions.mute}";
        "XF86AudioLowerVolume" = "exec ${i3-helpers.actions.voldn}";
        "XF86AudioRaiseVolume" = "exec ${i3-helpers.actions.volup}";
        "XF86MonBrightnessDown" = "exec ${i3-helpers.actions.bldec}";
        "XF86MonBrightnessUp" = "exec ${i3-helpers.actions.blinc}";
        "XF86Search" = "exec ${i3-helpers.pen-pye-menu}/bin/general_menu";
        "XF86AudioPrev" = "exec ${i3-helpers.actions.prev}";
        "XF86AudioPlay" = "exec ${i3-helpers.actions.toggle}";
        "XF86AudioNext" = "exec ${i3-helpers.actions.next}";
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
    extraConfig = ''
      popup_during_fullscreen leave_fullscreen
    '';
  };
}
