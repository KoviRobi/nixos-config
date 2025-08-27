{
  pkgs,
  config,
  ...
}:
let
  adwaita = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
  };
in
{
  imports = [
    ./i3
    ./restart-on-failure.nix
    "${
      fetchTarball {
        url = "https://github.com/KoviRobi/feh-random-background/archive/80bc3616bb8fc87225d1447431555230a4bf3b12.tar.gz";
        name = "feh-random-background";
        sha256 = "1hnwv33wmiaabkv7yqg6khc1aqrp01g2yv5l76bc47d80cj0amad";
      }
    }/home-manager-service.nix"
  ];

  programs.ghostty = {
    enable = true;
    settings = {
      confirm-close-surface = false;
      cursor-style = "block";
      cursor-style-blink = false;
      shell-integration-features = "no-cursor";
      font-family = "CaskaydiaCove NFM Light";
      font-family-italic = "CaskaydiaCove NFM SemiLight";
      font-family-bold = "CaskaydiaCove NFM";
      font-family-bold-italic = "CaskaydiaCove NFM";
      font-style = "Regular";
      font-style-italic = "Italic";
      font-style-bold = "Regular";
      font-style-bold-italic = "Italic";
      font-synthetic-style = false;
      font-size = 10.5;
      theme = "gruvbox";
      window-decoration = "server";
      keybind = [
        "clear"
        # "ctrl+comma=open_config"
        "shift+insert=paste_from_selection"
        # "ctrl+page_down=next_tab"
        "ctrl+shift+v=paste_from_clipboard"
        # "ctrl+alt+up=goto_split:up"
        # "ctrl+shift+a=select_all"
        # "super+ctrl+shift+plus=equalize_splits"
        # "shift+up=adjust_selection:up"
        # "alt+five=goto_tab:5"
        # "super+ctrl+right_bracket=goto_split:next"
        "ctrl+equal=increase_font_size:1"
        # "ctrl+shift+o=new_split:right"
        "ctrl+shift+c=copy_to_clipboard"
        # "ctrl+shift+q=quit"
        # "ctrl+shift+n=new_window"
        # "ctrl+shift+page_down=jump_to_prompt:1"
        "ctrl+shift+comma=reload_config"
        "ctrl+minus=decrease_font_size:1"
        # "shift+left=adjust_selection:left"
        # "super+ctrl+shift+up=resize_split:up,10"
        # "alt+eight=goto_tab:8"
        # "shift+page_up=scroll_page_up"
        # "ctrl+alt+shift+j=write_screen_file:open"
        # "ctrl+shift+left=previous_tab"
        # "ctrl+shift+w=close_tab"
        # "shift+end=scroll_to_bottom"
        "ctrl+zero=reset_font_size"
        # "alt+three=goto_tab:3"
        # "ctrl+shift+j=write_screen_file:paste"
        # "ctrl+enter=toggle_fullscreen"
        # "ctrl+page_up=previous_tab"
        # "shift+right=adjust_selection:right"
        # "ctrl+tab=next_tab"
        # "ctrl+alt+left=goto_split:left"
        # "shift+page_down=scroll_page_down"
        # "ctrl+shift+right=next_tab"
        # "ctrl+shift+page_up=jump_to_prompt:-1"
        # "alt+nine=last_tab"
        # "ctrl+shift+t=new_tab"
        # "shift+down=adjust_selection:down"
        # "super+ctrl+shift+left=resize_split:left,10"
        # "ctrl+shift+tab=previous_tab"
        # "alt+two=goto_tab:2"
        # "ctrl+alt+down=goto_split:down"
        # "super+ctrl+shift+down=resize_split:down,10"
        # "super+ctrl+shift+right=resize_split:right,10"
        # "ctrl+plus=increase_font_size:1"
        # "alt+four=goto_tab:4"
        # "ctrl+insert=copy_to_clipboard"
        # "ctrl+shift+e=new_split:down"
        # "ctrl+alt+right=goto_split:right"
        # "alt+f4=close_window"
        # "alt+one=goto_tab:1"
        # "ctrl+shift+enter=toggle_split_zoom"
        # "shift+home=scroll_to_top"
        # "super+ctrl+left_bracket=goto_split:previous"
        "ctrl+shift+i=inspector:toggle"
        # "alt+six=goto_tab:6"
        # "alt+seven=goto_tab:7"
      ];
    };
    themes = {
      gruvbox-dark = {
        background = "#282828";
        foreground = "#ebdbb2";
        cursor-color = "#ebdbb2";
        cursor-text = "#282828";
        selection-background = "#665c54";
        selection-foreground = "#ebdbb2";
        palette = [
          " 0=#282828" # 0:  black
          " 1=#cc241d" # 1:  red
          " 2=#98971a" # 2:  green
          " 3=#d79921" # 3:  yellow
          " 4=#458588" # 4:  blue
          " 5=#b16286" # 5:  magenta
          " 6=#689d6a" # 6:  cyan
          " 7=#a89984" # 7:  white
          " 8=#928374" # 8:  brblack
          " 9=#fb4934" # 9:  brred
          "10=#b8bb26" # 10: brgreen
          "11=#fabd2f" # 11: bryellow
          "12=#83a598" # 12: brblue
          "13=#d3869b" # 13: brmagenta
          "14=#8ec07c" # 14: brcyan
          "15=#ebdbb2" # 15: brwhite
        ];
      };

      gruvbox-light = {
        background = "#fbf1c7";
        foreground = "#282828";
        cursor-color = "#282828";
        cursor-text = "#fbf1c7";
        selection-background = "#d5c4a1";
        selection-foreground = "#665c54";
        palette = [
          " 0=#fbf1c7" # 0:  black
          " 1=#9d0006" # 1:  red
          " 2=#79740e" # 2:  green
          " 3=#b57614" # 3:  yellow
          " 4=#076678" # 4:  blue
          " 5=#8f3f71" # 5:  magenta
          " 6=#427b58" # 6:  cyan
          " 7=#3c3836" # 7:  white
          " 8=#9d8374" # 8:  brblack
          " 9=#cc241d" # 9:  brred
          "10=#98971a" # 10: brgreen
          "11=#d79921" # 11: bryellow
          "12=#458588" # 12: brblue
          "13=#b16186" # 13: brmagenta
          "14=#689d69" # 14: brcyan
          "15=#7c6f64" # 15: brwhite
        ];
      };
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "gtk";
  };

  services = {
    network-manager-applet.enable = true;
    copyq.enable = true;
    pasystray.enable = true;
    udiskie.enable = true;
    dunst.enable = true;
    dunst.settings = {
      global = {
        follow = "keyboard";
        mouse_middle_click = "context";
        dmenu = "${pkgs.dmenu}/bin/dmenu";
      };
    };
    darkman = {
      enable = true;
    }
    // (
      let
        f = brightness: {
          state-file = "echo '${brightness}' > ~/.local/state/brightness";
          ghostty = ''
            ${pkgs.coreutils}/bin/ln -srf                      \
                ~/.config/ghostty/themes/gruvbox-${brightness} \
                ~/.config/ghostty/themes/gruvbox
          '';
          kakoune = ''
            ${pkgs.kakoune}/bin/kak -l | while read sid; do
              echo "colorscheme gruvbox-${brightness}" | \
                  ${pkgs.kakoune}/bin/kak -p $sid
            done
          '';
          tmux = ''
          TMUX_TMPDIR=/run/user/$UID \
          ${pkgs.tmux}/bin/tmux source-file \
              ${pkgs.tmuxPlugins.gruvbox}/share/tmux-plugins/gruvbox/tmux-gruvbox-${brightness}.conf
          '';
        };
      in
      builtins.listToAttrs (
        map
          (name: {
            name = "${name}ModeScripts";
            value = f name;
          })
          [
            "light"
            "dark"
          ]
      )
    );
    feh-random-background = {
      enable = true;
      imageDirectory = "%h/backgrounds/";
      stateFile = "%h/.feh-random-background";
      interval = "1h";
      display = "max";
    };
    picom = {
      enable = true;
      menuOpacity = 1.0;
      opacityRules = [
        "100:class_i ?= 'i3lock'"
        "0:_NET_WM_STATE@:32a = '_NET_WM_STATE_HIDDEN'"
        "0:_NET_WM_STATE@[0]:32a = '_NET_WM_STATE_HIDDEN'"
        "0:_NET_WM_STATE@[1]:32a = '_NET_WM_STATE_HIDDEN'"
        "0:_NET_WM_STATE@[2]:32a = '_NET_WM_STATE_HIDDEN'"
        "0:_NET_WM_STATE@[3]:32a = '_NET_WM_STATE_HIDDEN'"
        "0:_NET_WM_STATE@[4]:32a = '_NET_WM_STATE_HIDDEN'"
        "87:class_i ?= 'scratchpad'"
        "91:class_i ?= 'st-256color'"
        "91:class_i ?= 'ghostty'"
        "100:focused"
      ];
    };
    xcape = {
      enable = true;
      mapExpression = {
        Shift_L = "parenleft";
        Shift_R = "parenright";
      };
      timeout = 250;
    };
  };

  xresources.properties = {
    "XTerm.termName" = "xterm-256color";
    "XTerm.backarrowKeyIsErase" = "true";
    "XTerm.ptyInitialErase" = "true";
    "XTerm.vt100.metaSendsEscape" = "true";
    "XTerm.vt100.faceSize" = "9";
    "XTerm.vt100.faceSize1" = "2";
    "XTerm.vt100.faceSize2" = "6";
    "XTerm.vt100.faceSize3" = "8";
    "XTerm.vt100.faceSize4" = "12";
    "XTerm.vt100.faceSize5" = "24";
    "XTerm.vt100.faceSize6" = "72";
    "XTerm.vt100.boldColors" = "false";
    "XTerm.vt100.faceName" = "xft:DejaVu Sans Mono";
    "XTerm.vt100.boldFont" = "xft:DejaVu Sans Mono";
  };

  xsession = {
    enable = true;
    initExtra = ''
      ~/.fehbg || true &
    '';
  };
  home.pointerCursor = adwaita // {
    size = builtins.div config.nixos.services.xserver.dpi 5;
  };
  gtk.theme = adwaita;
}
