{ pkgs, lib, ... }@args:
let
  i3 = "${pkgs.i3}";
  i3-helpers = import ./i3-helpers.nix pkgs;
  mod = "Mod4"; # Win key

  term = "${pkgs.st}/bin/st";
  maxima = "${pkgs.maxima}/bin/rmaxima";
  python3 = "${pkgs.python3.withPackages (p: with p; [ matplotlib numpy ])}/bin/python3";
  guile = "${pkgs.guile}/bin/guile";
  zsh = "${pkgs.zsh}/bin/zsh";
  emacs = "${pkgs.emacs}/bin/emacs";
  xclip = "${pkgs.xclip}/bin/xclip";
  rofi = "${pkgs.rofi}/bin/rofi";
  pgrep = "${pkgs.procps}/bin/pgrep";

  mk-scratch = n: p: pkgs.writeShellScript "start-scratch-${n}" ''
    ${pgrep} -f scratch_${n} > /dev/null || ${p}
  '';
  scratch = n: p: ''
    exec --no-startup-id '${mk-scratch n p}' ; \
    [instance="^scratch_${n}$"] scratchpad show
  '';
  scratch-term = n: p: scratch n "${term} -n 'scratch_${n}' -t 'scratch_${n}' -e '${p}'";
in
{
  xsession.windowManager.i3 = {
    enable = true;
    package = i3;
    config = {
      fonts = [ "Latin Modern Roman,Regular 9" ];
      bars = [{
        fonts = [ "Latin Modern Roman,Regular 9" ];
        statusCommand =
          "${pkgs.i3status}/bin/i3status -c ${import ./i3status-config.nix args}";
      }];
      modifier = mod;
      startup = [
        { command = "${i3-helpers.workspace-renumber}"; always = true; notification = false; }
      ];
      window.commands = [
        { command = "move scratchpad"; criteria = { instance = "^scratch_.*$"; }; }
        { command = "floating enable"; criteria = { title = "Ediff"; }; }
        { command = "floating enable"; criteria = { window_type = "popup_menu"; }; }
        { command = "border none"; criteria = { window_type = "popup_menu"; }; }
      ];
      keybindings = lib.mkOptionDefault ({
        "${mod}+Shift+c" = "kill";
        "${mod}+Return" = "exec ${term} -e ${i3-helpers.tmux-current-workspace}";
        "${mod}+Shift+Return" = "exec ${term}";
        "${mod}+p" = "exec ${i3-helpers.dmenu-run}";
        "${mod}+a" = "exec ${i3-helpers.dmenu-action}";
        "${mod}+Delete" = "exec ${i3-helpers.actions-dir}/lock";
        "${mod}+Shift+m" = scratch-term "maxima" maxima;
        "${mod}+Shift+p" = scratch-term "python" (pkgs.writeShellScript "scratchpy" "PYTHONSTARTUP=~/.pythonrc.scratch.py ${python3}");
        "${mod}+Shift+g" = scratch-term "guile" guile;
        "${mod}+Shift+s" = scratch-term "shell" zsh;
        "${mod}+Shift+e" = scratch "emacs" "${emacs} --name scratch_emacs";
        "${mod}+e" = ''exec emacsclient -a "" -c'';
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
        "${mod}+u" = "exec ${i3-helpers.unipicker}/bin/unipicker " +
          "--copy-command '${xclip} -sel pri -f | ${xclip} -sel clip' " +
          "--command '${rofi} -dmenu -matching regex'";
        "${mod}+Control+Shift+r" = "restart";
        "${mod}+bracketleft" = "focus output left";
        "${mod}+bracketright" = "focus output right";
        "${mod}+parenleft" = "workspace prev_on_output";
        "${mod}+parenright" = "workspace next_on_output";
        "${mod}+Shift+bracketleft" = "move to output left";
        "${mod}+Shift+bracketright" = "move to output right";
        "${mod}+Shift+parenleft" = "move to workspace prev_on_output";
        "${mod}+Shift+parenright" = "move to workspace next_on_output";
        "--whole-window ${mod}+button2" = "exec ${i3-helpers.pen-pye-menu}/bin/general_menu";
        "--release button2" = "exec ${i3-helpers.pen-pye-menu}/bin/window_menu";
        "XF86AudioMute" = "exec ${i3-helpers.actions-dir}/mute";
        "XF86AudioLowerVolume" = "exec ${i3-helpers.actions-dir}/voldn";
        "XF86AudioRaiseVolume" = "exec ${i3-helpers.actions-dir}/volup";
        "XF86MonBrightnessDown" = "exec ${i3-helpers.actions-dir}/bldec";
        "XF86MonBrightnessUp" = "exec ${i3-helpers.actions-dir}/blinc";
        "XF86Search" = "exec ${i3-helpers.pen-pye-menu}/bin/general_menu";
        "XF86AudioPrev" = "exec ${i3-helpers.actions-dir}/prev";
        "XF86AudioNext" = "exec ${i3-helpers.actions-dir}/next";
        "Shift+XF86AudioPrev" = "exec ${i3-helpers.actions-dir}/back";
        "Shift+XF86AudioNext" = "exec ${i3-helpers.actions-dir}/forward";
        "XF86AudioPlay" = "exec ${i3-helpers.actions-dir}/toggle";
      } //
      (builtins.listToAttrs (
        (
          builtins.genList
            (n:
              let m = toString (n + 1); in
              {
                name = "${mod}+${m}";
                value = "exec ${i3-helpers.workspace-action} 'workspace' ${m}";
              })
            9
        ) ++
        (
          builtins.genList
            (n:
              let m = toString (n + 1); in
              {
                name = "${mod}+Shift+${m}";
                value = "exec ${i3-helpers.workspace-action} 'move container to workspace' ${m}";
              })
            9
        )
      )));
    };
    extraConfig = ''
      popup_during_fullscreen leave_fullscreen
    '';
  };
}
