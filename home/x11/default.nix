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
      font-family = "CaskaydiaCove NFM Light";
      font-size = 10.5;
      theme = "light:solarized-light,dark:solarized-dark";
      window-decoration = "server";
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
