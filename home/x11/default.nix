{
  pkgs,
  lib,
  config,
  ...
}:
let
  killall = "${pkgs.psmisc}/bin/killall";
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

  services.network-manager-applet.enable = true;
  services.parcellite.enable = true;
  services.pasystray.enable = true;
  services.udiskie.enable = true;
  services.dunst.enable = true;
  services.dunst.settings = {
    global = {
      follow = "keyboard";
      mouse_middle_click = "context";
      dmenu = "${pkgs.dmenu}/bin/dmenu";
    };
  };
  services.feh-random-background = {
    enable = true;
    imageDirectory = "%h/backgrounds/";
    stateFile = "%h/.feh-random-background";
    interval = "1h";
    display = "max";
  };
  services.picom = {
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
      "100:focused"
    ];
  };
  services.xcape = {
    enable = true;
    mapExpression = {
      Shift_L = "parenleft";
      Shift_R = "parenright";
    };
    timeout = 250;
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
