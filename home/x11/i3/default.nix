{
  config,
  pkgs,
  lib,
  ...
}@args:
let
  xprop = name: config.xresources.properties."*.${name}";
  border = config.xsession.windowManager.i3.config.window.border;
  i3-helpers = import ./i3-helpers.nix args;
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
  scratch-term = n: p: scratch n "${term} start --class='scratch_${n}' -e ${p}";
in
{
  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3;
    config = {
      keybindings = {};
      modes = {};
      fonts = {
        names = [ "CaskaydiaMono NF" ];
        style = "Regular";
        size = 10.0;
      };
      window.border = 4;
      floating.border = 4;
      bars = [];
      modifier = "Mod4";
      colors = lib.mkForce {};
    };
    extraConfig = ''
      popup_during_fullscreen leave_fullscreen
      no_focus [window_role="pop-up"]

      set_from_resource $gray   i3wm.gray   ${xprop "gray"}
      set_from_resource $red    i3wm.red    ${xprop "red"}
      set_from_resource $green  i3wm.green  ${xprop "green"}#79740E
      set_from_resource $yellow i3wm.yellow ${xprop "yellow"}#B57614
      set_from_resource $blue   i3wm.blue   ${xprop "blue"}#876678
      set_from_resource $purple i3wm.purple ${xprop "purple"}#8F3F71
      set_from_resource $aqua   i3wm.aqua   ${xprop "aqua"}#427B58
      set_from_resource $orange i3wm.orange ${xprop "orange"}#AF3A03
      set_from_resource $bg0    i3wm.bg0    ${xprop "bg0"}#FBF1C7
      set_from_resource $bg1    i3wm.bg1    ${xprop "bg1"}#EBDBB2
      set_from_resource $bg2    i3wm.bg2    ${xprop "bg2"}#D5C4A1
      set_from_resource $bg3    i3wm.bg3    ${xprop "bg3"}#BDAE93
      set_from_resource $bg4    i3wm.bg4    ${xprop "bg4"}#A89984
      set_from_resource $fg0    i3wm.fg0    ${xprop "fg0"}#3C3836
      set_from_resource $fg1    i3wm.fg1    ${xprop "fg1"}#282828
      set_from_resource $fg2    i3wm.fg2    ${xprop "fg2"}#504945
      set_from_resource $fg3    i3wm.fg3    ${xprop "fg3"}#665C54
      set_from_resource $fg4    i3wm.fg4    ${xprop "fg4"}#7C6F64

      # class                 border  backgr. text    indicator child_border
      client.focused          $bg2    $bg2    $fg0    $bg0      $bg2
      client.focused_inactive $bg1    $bg1    $fg2    $bg0      $bg1
      client.unfocused        $bg0    $bg0    $fg3    $bg0      $bg0
      client.urgent           $fg1    $fg1    $bg1    $purple   $red
      client.placeholder      $fg2    $fg2    $bg2    $bg4      $fg2
      client.background       $bg0

      bindsym Mod4+1 workspace number 1
      bindsym Mod4+2 workspace number 2
      bindsym Mod4+3 workspace number 3
      bindsym Mod4+4 workspace number 4
      bindsym Mod4+5 workspace number 5
      bindsym Mod4+6 workspace number 6
      bindsym Mod4+7 workspace number 7
      bindsym Mod4+8 workspace number 8
      bindsym Mod4+9 workspace number 9
      bindsym Mod4+0 workspace number 10

      bindsym Mod4+Shift+1 move container to workspace number 1
      bindsym Mod4+Shift+2 move container to workspace number 2
      bindsym Mod4+Shift+3 move container to workspace number 3
      bindsym Mod4+Shift+4 move container to workspace number 4
      bindsym Mod4+Shift+5 move container to workspace number 5
      bindsym Mod4+Shift+6 move container to workspace number 6
      bindsym Mod4+Shift+7 move container to workspace number 7
      bindsym Mod4+Shift+8 move container to workspace number 8
      bindsym Mod4+Shift+9 move container to workspace number 9
      bindsym Mod4+Shift+0 move container to workspace number 10

      bindsym Mod1+Mod4+h exec --no-startup-id ${lib.getExe' pkgs.ringboard "ringboard-egui"} toggle

      bindsym Mod4+Control+Shift+r restart
      bindsym Mod4+Control+h split v
      bindsym Mod4+Control+s layout stacking
      bindsym Mod4+Control+t layout tabbed
      bindsym Mod4+Control+v split h
      bindsym Mod4+e layout toggle split

      bindsym Mod4+Left focus left
      bindsym Mod4+Down focus down
      bindsym Mod4+Up focus up
      bindsym Mod4+Right focus right

      bindsym Mod4+h focus left
      bindsym Mod4+j focus down
      bindsym Mod4+k focus up
      bindsym Mod4+l focus right

      bindsym Mod4+Home focus output left
      bindsym Mod4+Next focus output down
      bindsym Mod4+Prior focus output up
      bindsym Mod4+End focus output right

      bindsym Mod4+Shift+Left move left
      bindsym Mod4+Shift+Down move down
      bindsym Mod4+Shift+Up move up
      bindsym Mod4+Shift+Right move right

      bindsym Mod4+Shift+h move left
      bindsym Mod4+Shift+j move down
      bindsym Mod4+Shift+k move up
      bindsym Mod4+Shift+l move right

      bindsym Mod4+Shift+Prior move to output up
      bindsym Mod4+Shift+Next move to output down
      bindsym Mod4+Shift+Home move to output left
      bindsym Mod4+Shift+End move to output right

      bindsym Mod4+Return exec ${term}
      bindsym Mod4+Shift+Return exec ${term}
      bindsym Mod4+Shift+backslash move to workspace prev_on_output
      bindsym Mod4+Shift+bracketleft move to output left
      bindsym Mod4+Shift+bracketright move to output right
      bindsym Mod4+Shift+c kill
      bindsym Mod4+Shift+e exec i3-nagbar -t warning -m 'Do you want to exit i3?' -b 'Yes' 'i3-msg exit'
      bindsym Mod4+Shift+equal move to workspace next_on_output

      bindsym Mod4+Shift+minus move scratchpad
      bindsym Mod4+Shift+g ${scratch-term "guile" guile}
      bindsym Mod4+Shift+m ${scratch-term "maxima" maxima}
      bindsym Mod4+Shift+p ${scratch-term "python" (pkgs.writeShellScript "scratchpy" "${python3}")}
      bindsym Mod4+Shift+s ${scratch-term "shell" ""}

      bindsym Mod4+Shift+q kill
      bindsym Mod4+Shift+r reload

      bindsym Mod4+comma exec ${lib.getExe' pkgs.dunst "dunstctl"} history-pop
      bindsym Mod4+period exec ${lib.getExe' pkgs.dunst "dunstctl"} close
      bindsym Mod4+slash exec ${lib.getExe' pkgs.dunst "dunstctl"} context

      bindsym Mod4+Shift+space floating toggle

      bindsym Mod4+t exec mark --add "_sel";\
          exec ${i3-helpers.dmenu-workspace} workspace
      bindsym Mod4+Shift+t mark --add "_sel";\
          exec ${i3-helpers.dmenu-workspace} '[con_mark="_sel"]' move container to workspace
      bindsym Mod4+a exec ${i3-helpers.dmenu-action}
      bindsym Mod4+p exec ${i3-helpers.dmenu-run}
      bindsym Mod4+d exec ${i3-helpers.dmenu-drun}
      bindsym Mod4+g exec ${i3-helpers.dmenu-window}
      bindsym Mod4+u exec ${lib.getExe pkgs.unipicker} \
                            --copy-command '${xsel-both}' \
                            --command '${rofi} -case-smart -sorting-method fzf -dmenu -matching regex'

      bindsym Mod4+backslash workspace prev_on_output
      bindsym Mod4+bracketleft focus output left
      bindsym Mod4+bracketright focus output right

      bindsym Mod4+equal workspace next_on_output
      bindsym Mod4+f fullscreen toggle
      bindsym Mod4+minus scratchpad show
      bindsym Mod4+r mode resize
      bindsym Mod4+s focus child
      bindsym Mod4+space focus mode_toggle
      bindsym Mod4+v split v
      bindsym Mod4+w focus parent

      bindsym Mod4+Delete exec ${i3-helpers.actions-dir}/lock
      bindsym XF86AudioPlay exec ${i3-helpers.actions-dir}/toggle
      bindsym XF86AudioPrev exec ${i3-helpers.actions-dir}/prev
      bindsym XF86AudioNext exec ${i3-helpers.actions-dir}/next
      bindsym Shift+XF86AudioPrev exec ${i3-helpers.actions-dir}/back
      bindsym Shift+XF86AudioNext exec ${i3-helpers.actions-dir}/forward

      bindsym XF86AudioMute exec ${i3-helpers.actions-dir}/mute
      bindsym XF86AudioLowerVolume exec ${i3-helpers.actions-dir}/voldn
      bindsym XF86AudioRaiseVolume exec ${i3-helpers.actions-dir}/volup

      bindsym XF86Launch5 exec ${i3-helpers.actions-dir}/toggle

      bindsym XF86MonBrightnessDown exec ${i3-helpers.actions-dir}/bldec
      bindsym XF86MonBrightnessUp exec ${i3-helpers.actions-dir}/blinc

      bindsym XF86Search exec ${i3-helpers.pen-pye-menu}/bin/pen_menu
      bindsym --release button2 exec ${i3-helpers.pen-pye-menu}/bin/pen_menu
      bindsym --whole-window Mod4+button2 exec ${i3-helpers.pen-pye-menu}/bin/pen_menu

      mode "resize" {
        bindsym Down resize grow height 10 px or 10 ppt
        bindsym Escape mode default
        bindsym Left resize shrink width 10 px or 10 ppt
        bindsym Return mode default
        bindsym Right resize grow width 10 px or 10 ppt
        bindsym Up resize shrink height 10 px or 10 ppt
      }

      bar {
        font pango:CaskaydiaMono NF Regular 10.0
        status_command ${lib.getExe pkgs.i3status} -c ${import ./i3status-config.nix args}
        i3bar_command ${lib.getExe' pkgs.i3 "i3bar"}
        separator_symbol "┃"
        strip_workspace_numbers no
        strip_workspace_name    no
        colors {
            background $bg0
            statusline $fg2
            separator  $bg4

            focused_workspace  $fg0 $fg0 $bg0
            active_workspace   $fg2 $fg2 $bg2
            inactive_workspace $bg2 $bg2 $fg2
            urgent_workspace   $purple $red $fg1
            binding_mode       $bg3 $bg3 $fg3
        }
      }

      for_window [instance="^ringboard-egui$"] floating enable
      for_window [instance="^scratch_.*$"] move scratchpad
      for_window [instance="^scratch_.*$"] scratchpad show
      for_window [title="Ediff"] floating enable
      for_window [window_type="popup_menu"] floating enable
      for_window [class="Display" instance="display"] floating enable
      for_window [class="Dragon-drop" instance="dragon-drop"] floating enable
      for_window [class="Dragon-drop" instance="dragon-drop"] border none
      for_window [window_type="popup_menu"] border none
      for_window [class="mpv"] border pixel 1
      for_window [class="Vncviewer"] border pixel 1
      for_window [class="librewolf"] border pixel ${toString border}

      exec_always --no-startup-id ${i3-helpers.workspace-renumber}
    '';
  };
}
