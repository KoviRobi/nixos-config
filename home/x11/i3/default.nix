{ pkgs, config, lib, pye-menu, ... }@args:
let
  i3-helpers = import ./i3-helpers.nix { inherit pkgs pye-menu; };
  mod = "Mod4"; # Win key

  term = "${pkgs.st}/bin/st";
  maxima = "${pkgs.maxima}/bin/rmaxima";
  python3 = "${pkgs.python3.withPackages (p: with p; [ matplotlib numpy ])}/bin/python3";
  guile = "${pkgs.guile}/bin/guile";
  zsh = "${pkgs.zsh}/bin/zsh";
  emacs = "${pkgs.emacs}/bin/emacs";
  xclip = "${pkgs.xclip}/bin/xclip";
  rofi = "${pkgs.rofi}/bin/rofi";
  unipicker = "${pkgs.unipicker}/bin/unipicker";
  xclip-both = pkgs.writeShellScript "xclip-both" ''
    ${xclip} -sel pri -f | ${xclip} -sel clip
  '';
  pgrep = "${pkgs.procps}/bin/pgrep";

  mk-scratch = n: p: pkgs.writeShellScript "start-scratch-${n}" ''
    ${pgrep} -f scratch_${n} > /dev/null || exec ${p}
  '';
  scratch = n: p: ''
    exec --no-startup-id '${mk-scratch n p}' , \
    [instance="^scratch_${n}$"] scratchpad show
  '';
  scratch-term = n: p: scratch n "${term} -n 'scratch_${n}' -t 'scratch_${n}' -e ${p}";
in
{
  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3;
    config = {
      fonts = { names = [ "Latin Modern Roman" ]; style = "Regular"; size = 9.0; };
      bars = [{
        fonts = { names = [ "Latin Modern Roman" ]; style = "Regular"; size = 9.0; };
        statusCommand =
          "${pkgs.i3status}/bin/i3status -c ${import ./i3status-config.nix args}";
      }];
      modifier = mod;
      startup = [
        { command = "${i3-helpers.workspace-renumber}"; always = true; notification = false; }
      ];
      window.commands = [
        { command = "move scratchpad"; criteria = { instance = "^scratch_.*$"; }; }
        { command = "scratchpad show"; criteria = { instance = "^scratch_.*$"; }; }
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
        "${mod}+Shift+s" = scratch-term "shell" "${pkgs.tmux}/bin/tmux -f ${config.xdg.configHome}/tmux/tmux.conf attach-session -d -t float";
        "${mod}+Shift+e" = scratch "emacs" "${emacs} --name scratch_emacs";

        "${mod}+e" = "layout toggle split";
        "${mod}+Control+h" = "split v";
        "${mod}+Control+v" = "split h";
        "${mod}+Control+s" = "layout stacking";
        "${mod}+Control+t" = "layout tabbed";

        "${mod}+h" = "focus left";
        "${mod}+j" = "focus down";
        "${mod}+k" = "focus up";
        "${mod}+l" = "focus right";
        "${mod}+Shift+h" = "move left";
        "${mod}+Shift+j" = "move down";
        "${mod}+Shift+k" = "move up";
        "${mod}+Shift+l" = "move right";

        "${mod}+w" = "focus parent";
        "${mod}+d" = "focus child";
        "${mod}+t" = "exec ${i3-helpers.dmenu-workspace} 'workspace'";
        "${mod}+Shift+t" = "exec ${i3-helpers.dmenu-workspace} 'move container to workspace'";
        "${mod}+Shift+r" = "reload";
        "${mod}+u" = "exec ${unipicker} --copy-command '${xclip-both}' " +
          "--command '${rofi} -dmenu -matching regex'";
        "${mod}+Control+Shift+r" = "restart";
        "${mod}+bracketleft" = "focus output prev";
        "${mod}+bracketright" = "focus output next";
        "${mod}+parenleft" = "workspace prev_on_output";
        "${mod}+parenright" = "workspace next_on_output";
        "${mod}+Shift+bracketleft" = "move to output prev";
        "${mod}+Shift+bracketright" = "move to output next";
        "${mod}+Shift+parenleft" = "move to workspace prev_on_output";
        "${mod}+Shift+parenright" = "move to workspace next_on_output";
        "--whole-window ${mod}+button2" = "exec ${i3-helpers.pen-pye-menu}/bin/pen_menu";
        "--release button2" = "exec ${i3-helpers.pen-pye-menu}/bin/pen_menu";
        "XF86AudioMute" = "exec ${i3-helpers.actions-dir}/mute";
        "XF86AudioLowerVolume" = "exec ${i3-helpers.actions-dir}/voldn";
        "XF86AudioRaiseVolume" = "exec ${i3-helpers.actions-dir}/volup";
        "XF86MonBrightnessDown" = "exec ${i3-helpers.actions-dir}/bldec";
        "XF86MonBrightnessUp" = "exec ${i3-helpers.actions-dir}/blinc";
        "XF86Search" = "exec ${i3-helpers.pen-pye-menu}/bin/pen_menu";
        "XF86AudioPrev" = "exec ${i3-helpers.actions-dir}/prev";
        "XF86AudioNext" = "exec ${i3-helpers.actions-dir}/next";
        "Shift+XF86AudioPrev" = "exec ${i3-helpers.actions-dir}/back";
        "Shift+XF86AudioNext" = "exec ${i3-helpers.actions-dir}/forward";
        "XF86AudioPlay" = "exec ${i3-helpers.actions-dir}/toggle";
        "XF86Launch5" = "exec ${i3-helpers.actions-dir}/toggle";
        # Dunst
        "${mod}+Prior" = "exec ${pkgs.dunst}/bin/dunstctl close";
        "${mod}+Next" = "exec ${pkgs.dunst}/bin/dunstctl history-pop";
        "${mod}+period" = "exec ${pkgs.dunst}/bin/dunstctl context";
      } //
      (builtins.listToAttrs (
        (
          builtins.genList
            (n:
              let m = if n == 0 then "10" else toString n; in
              {
                name = "${mod}+${toString n}";
                value = "workspace ${m}";
              })
            10
        ) ++
        (
          builtins.genList
            (n:
              let m = if n == 0 then "10" else toString n; in
              {
                name = "${mod}+Shift+${toString n}";
                value = "move container to workspace ${m}";
              })
            10
        )
      )));
      defaultWorkspace = "workspace 1";
    };
    extraConfig = ''
      popup_during_fullscreen leave_fullscreen
    '';
  };
}
