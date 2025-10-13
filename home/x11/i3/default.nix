{
  pkgs,
  lib,
  ...
}@args:
let
  i3-helpers = import ./i3-helpers.nix { inherit pkgs; };
  mod = "Mod4"; # Win key

  term = lib.getExe pkgs.wezterm;
  maxima = "${pkgs.maxima}/bin/rmaxima";
  python3 = "${
    pkgs.python3.withPackages (
      p: with p; [
        matplotlib
        numpy
      ]
    )
  }/bin/python3";
  guile = "${pkgs.guile}/bin/guile";
  xsel = lib.getExe pkgs.xsel;
  rofi = "${pkgs.rofi}/bin/rofi";
  unipicker = "${pkgs.unipicker}/bin/unipicker";
  xsel-both = pkgs.writeShellScript "xsel-both" ''
    ${xsel} -i
    ${xsel} | ${xsel} -i -b
  '';
  pgrep = "${pkgs.procps}/bin/pgrep";

  mk-scratch =
    n: p:
    pkgs.writeShellScript "start-scratch-${n}" ''
      ${pgrep} -f scratch_${n} > /dev/null || exec ${p}
    '';
  scratch = n: p: ''
    exec --no-startup-id '${mk-scratch n p}' , \
    [instance="^scratch_${n}$"] scratchpad show
  '';
  scratch-term =
    n: p: scratch n "${term} --title='scratch_${n}' --x11-instance-name='scratch_${n}' -e ${p}";
in
{
  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3;
    config = {
      fonts = {
        names = [ "CaskaydiaMono NF" ];
        style = "Regular";
        size = 9.0;
      };
      bars = [
        {
          fonts = {
            names = [ "CaskaydiaMono NF" ];
            style = "Regular";
            size = 9.0;
          };
          statusCommand = "${pkgs.i3status}/bin/i3status -c ${import ./i3status-config.nix args}";
        }
      ];
      modifier = mod;
      startup = [
        {
          command = "${i3-helpers.workspace-renumber}";
          always = true;
          notification = false;
        }
      ];
      window.commands = [
        {
          command = "move scratchpad";
          criteria = {
            instance = "^scratch_.*$";
          };
        }
        {
          command = "scratchpad show";
          criteria = {
            instance = "^scratch_.*$";
          };
        }
        {
          command = "floating enable";
          criteria = {
            title = "Ediff";
          };
        }
        {
          command = "floating enable";
          criteria = {
            window_type = "popup_menu";
          };
        }
        {
          command = "floating enable";
          criteria = {
            instance = "display"; # ImageMagick
            class = "Display";
          };
        }
        {
          command = "floating enable";
          criteria = {
            instance = "dragon-drop";
            class = "Dragon-drop";
          };
        }
        {
          command = "border none";
          criteria = {
            instance = "dragon-drop";
            class = "Dragon-drop";
          };
        }
        {
          command = "border none";
          criteria = {
            window_type = "popup_menu";
          };
        }
        {
          command = "border 1pixel";
          criteria = {
            class = "mpv";
            floating = true;
          };
        }
      ];
      keybindings =
        lib.mkOptionDefault {
          "${mod}+Shift+c" = "kill";
          "${mod}+Return" = "exec ${term} -e ${i3-helpers.tmux-current-workspace}";
          "${mod}+Shift+Return" = "exec ${term}";
          "${mod}+p" = "exec ${i3-helpers.dmenu-run}";
          "${mod}+g" = "exec ${i3-helpers.dmenu-window}";
          "${mod}+d" = "exec ${i3-helpers.dmenu-drun}";
          "${mod}+a" = "exec ${i3-helpers.dmenu-action}";
          "${mod}+Delete" = "exec ${i3-helpers.actions-dir}/lock";
          "${mod}+Shift+m" = scratch-term "maxima" maxima;
          "${mod}+Shift+p" = scratch-term "python" (
            pkgs.writeShellScript "scratchpy" "${python3}"
          );
          "${mod}+Shift+g" = scratch-term "guile" guile;
          "${mod}+Shift+s" = scratch-term "shell" "${pkgs.tmux}/bin/tmux new -t float";

          "${mod}+e" = "layout toggle split";
          "${mod}+Control+h" = "split v";
          "${mod}+Control+v" = "split h";
          "${mod}+Control+s" = "layout stacking";
          "${mod}+Control+t" = "layout tabbed";

          "${mod}+h" = "focus left";
          "${mod}+j" = "focus down";
          "${mod}+k" = "focus up";
          "${mod}+l" = "focus right";
          "${mod}+Left" = "focus left";
          "${mod}+Right" = "focus right";
          "${mod}+Up" = "focus up";
          "${mod}+Down" = "focus down";
          "${mod}+Home" = "focus output left";
          "${mod}+End" = "focus output right";
          "${mod}+Prior" = "focus output up";
          "${mod}+Next" = "focus output down";
          "${mod}+Shift+h" = "move left";
          "${mod}+Shift+j" = "move down";
          "${mod}+Shift+k" = "move up";
          "${mod}+Shift+l" = "move right";
          "${mod}+Shift+Left" = "move left";
          "${mod}+Shift+Right" = "move right";
          "${mod}+Shift+Up" = "move up";
          "${mod}+Shift+Down" = "move down";
          "${mod}+Shift+Home" = "move to output left";
          "${mod}+Shift+End" = "move to output right";
          "${mod}+Shift+Prior" = "move to output up";
          "${mod}+Shift+Next" = "move to output down";

          "${mod}+w" = "focus parent";
          "${mod}+s" = "focus child";
          "${mod}+t" = "exec ${i3-helpers.dmenu-workspace} 'workspace'";
          "${mod}+Shift+t" = "exec ${i3-helpers.dmenu-workspace} 'move container to workspace'";
          "${mod}+Shift+r" = "reload";
          "${mod}+u" =
            "exec ${unipicker} --copy-command '${xsel-both}' " + "--command '${rofi} -dmenu -matching regex'";
          "${mod}+Control+Shift+r" = "restart";
          "${mod}+bracketleft" = "focus output left";
          "${mod}+bracketright" = "focus output right";
          "${mod}+parenleft" = "workspace prev_on_output";
          "${mod}+parenright" = "workspace next_on_output";
          "${mod}+Shift+bracketleft" = "move to output left";
          "${mod}+Shift+bracketright" = "move to output right";
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
          "${mod}+comma" = "exec ${pkgs.dunst}/bin/dunstctl close";
          "${mod}+period" = "exec ${pkgs.dunst}/bin/dunstctl history-pop";
          "${mod}+slash" = "exec ${pkgs.dunst}/bin/dunstctl context";
        }
        // {
          # Unset not used defaults
          "${mod}+Shift+q" = lib.mkForce null;
          "${mod}+v" = lib.mkForce null;
          "${mod}+s" = lib.mkForce null;
        };
    };
    extraConfig = ''
      popup_during_fullscreen leave_fullscreen
      no_focus [window_role="pop-up"]
    '';
  };
}
