{ pkgs, lib, config, ... }:
let
  killall = "${pkgs.psmisc}/bin/killall";
  adwaita = { name = "Adwaita"; package = pkgs.gnome.adwaita-icon-theme; };
in
{
  imports = [
    ./i3
    ./restart-on-failure.nix
    "${fetchTarball {
        url = https://github.com/KoviRobi/feh-random-background/archive/0154eb1d1fb2b5774a6908bee1f3b3ebd3317ac6.tar.gz;
        sha256 = "1gwpk968h8js0ddi84hpqgh5mqijr9y5xgyiz8bfh9hm39wdjxm2";
    } }/home-manager-service.nix"
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
  home.pointerCursor = adwaita // { size = builtins.div config.nixos.services.xserver.dpi 5; };
  gtk.theme = adwaita;
}
