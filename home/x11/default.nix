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
      theme = "light:solarized-light,dark:solarized-dark";
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
        # "ctrl+shift+comma=reload_config"
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
      solarized-dark = {
        # defaultfg = 12;
        # defaultbg = 8;
        # defaultcs = 14;
        # defaultrcs = 15;
        background = "#002b36";
        foreground = "#839496";
        cursor-color = "#93a1a1";
        cursor-text = "#fdf6e3";
        palette = [
          " 0=#073642" # 0:  black
          " 1=#dc322f" # 1:  red
          " 2=#859900" # 2:  green
          " 3=#b58900" # 3:  yellow
          " 4=#268bd2" # 4:  blue
          " 5=#d33682" # 5:  magenta
          " 6=#2aa198" # 6:  cyan
          " 7=#eee8d5" # 7:  white
          " 8=#002b36" # 8:  brblack
          " 9=#cb4b16" # 9:  brred
          "10=#586e75" # 10: brgreen
          "11=#657b83" # 11: bryellow
          "12=#839496" # 12: brblue
          "13=#6c71c4" # 13: brmagenta
          "14=#93a1a1" # 14: brcyan
          "15=#fdf6e3" # 15: brwhite
        ];
      };

      solarized-light = {
        background = "#fdf6e3";
        foreground = "#657b83";
        cursor-color = "#586e75";
        cursor-text = "#002b36";
        palette = [
          " 0=#eee8d5" # 0:  black
          " 1=#dc322f" # 1:  red
          " 2=#859900" # 2:  green
          " 3=#b58900" # 3:  yellow
          " 4=#268bd2" # 4:  blue
          " 5=#d33682" # 5:  magenta
          " 6=#2aa198" # 6:  cyan
          " 7=#073642" # 7:  white
          " 8=#fdf6e3" # 8:  brblack
          " 9=#cb4b16" # 9:  brred
          "10=#93a1a1" # 10: brgreen
          "11=#839496" # 11: bryellow
          "12=#657b83" # 12: brblue
          "13=#6c71c4" # 13: brmagenta
          "14=#586e75" # 14: brcyan
          "15=#002b36" # 15: brwhite
        ];
      };
    };
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
      darkModeScripts.state-file = "echo 'dark' > ~/.local/state/brightness";
      lightModeScripts.state-file = "echo 'light' > ~/.local/state/brightness";
    };
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
