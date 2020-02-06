{ pkgs, lib, config, ... }:
let killall = "${pkgs.psmisc}/bin/killall";
    adwaita = { name = "Adwaita"; package = pkgs.gnome3.adwaita-icon-theme; };
in {
  imports = [ ./i3
              ../modules/import-dpi.nix
              "${fetchGit https://github.com/KoviRobi/feh-random-background.git
               }/home-manager-service.nix"
            ];

  services.network-manager-applet.enable = true;
  services.parcellite.enable = true;
  services.pasystray.enable = true;
  services.dunst.enable = true;
  services.dunst.settings = {
    global = { follow = "keyboard"; };
    shortcuts = { close = "mod4+Prior"; history = "mod4+Next"; };
  };
  home.file.backgrounds = { recursive = true; source = ./backgrounds; };
  services.feh-random-background = {
    enable = true;
    imageDirectory = "%h/backgrounds/";
    stateFile = "%h/.feh-random-background";
    interval = "1h";
    display = "max";
  };
  services.screen-locker = {
    enable = true;
    lockCmd = ''${pkgs.writeShellScript "lock-screen-dunst-i3lock" ''
      ${killall} -SIGUSR1 dunst # pause
      ( i3lock -n; ${killall} -SIGUSR2 dunst ) &
    ''}'';
    xautolockExtraOptions = [ "-corners" "----" ];
  };
  services.compton = { enable = true;
    menuOpacity = "1.0";
    opacityRule = [
      "100:class_i ?= 'i3lock'"
      "0:_NET_WM_STATE@:32a = '_NET_WM_STATE_HIDDEN'"
      "0:_NET_WM_STATE@[0]:32a = '_NET_WM_STATE_HIDDEN'"
      "0:_NET_WM_STATE@[1]:32a = '_NET_WM_STATE_HIDDEN'"
      "0:_NET_WM_STATE@[2]:32a = '_NET_WM_STATE_HIDDEN'"
      "0:_NET_WM_STATE@[3]:32a = '_NET_WM_STATE_HIDDEN'"
      "0:_NET_WM_STATE@[4]:32a = '_NET_WM_STATE_HIDDEN'"
      "80:!focused"
      "100:wmwin"
      "87:class_i ?= 'scratchpad'"
      "91:class_i ?= 'xterm'"
      "91:class_i ?= 'mpv'"
      "100:focused"
    ];
  };

  xresources.extraConfig = builtins.readFile (
    pkgs.fetchFromGitHub {
      owner = "solarized";
      repo = "xresources";
      rev = "025ceddbddf55f2eb4ab40b05889148aab9699fc";
      sha256 = "0lxv37gmh38y9d3l8nbnsm1mskcv10g3i83j0kac0a2qmypv1k9f";
    } + "/Xresources.dark");
  xresources.properties = {
    "XTerm.termName" = "xterm-256color";
    "XTerm.backarrowKeyIsErase"   = "true";
    "XTerm.ptyInitialErase"       = "true";
    "XTerm.vt100.metaSendsEscape" = "true";
    "XTerm.vt100.faceSize"        = "9";
    "XTerm.vt100.faceSize1"       = "2";
    "XTerm.vt100.faceSize2"       = "6";
    "XTerm.vt100.faceSize3"       = "8";
    "XTerm.vt100.faceSize4"       = "12";
    "XTerm.vt100.faceSize5"       = "24";
    "XTerm.vt100.faceSize6"       = "72";
    "XTerm.vt100.boldColors"      = "false";
    "XTerm.vt100.faceName"        = "xft:DejaVu Sans Mono";
    "XTerm.vt100.boldFont"        = "xft:DejaVu Sans Mono";
  };

  xsession = {
    enable = true;
    initExtra = "~/.fehbg || true &";
    pointerCursor = adwaita // { size = builtins.div config.dpi 5; };
  };
  gtk.theme = adwaita;
}
