# vim: set ts=2 sts=2 sw=2 et :
{ config, pkgs, lib, ... }:

{ environment.systemPackages = with pkgs;
  [ xclip
    hicolor-icon-theme gnome3.adwaita-icon-theme
    libnotify
    chromium mpv ffmpeg compton zathura
  ] ++ (with xorg; [ xkbprint xkbutils ]);

  services.xserver =
  { enable = true; layout = "us";
    displayManager.defaultSession = "none+i3";
    displayManager.lightdm = {
      enable = true;
      autoLogin = { enable = true; user = config.users.users.default-user.name; };
      greeters.gtk.cursorTheme.package = pkgs.gnome3.adwaita-icon-theme;
      greeters.gtk.cursorTheme.name = "Adwaita";
    };
    windowManager.i3.enable = true;
    exportConfiguration = true;
    inputClassSections = [ ''
      Identifier "Kensington SlimBlade"
      MatchProduct "Kensington Kensington Slimblade Trackball"
      Driver "evdev"
      Option "ButtonMapping" "1 10 3 8 9 6 7 2 4 5 11 12"
      Option "EmulateWheel" "1"
      Option "EmulateWheelButton" "2"
      Option "XAxisMapping" "6 7
      Option "YAxisMapping" "9 10"
      Option "EmulateWheelInertia" "5"
      Option "Device Accel Profile" "-1"
    ''
    ''
      Identifier "ELECOM HUGE TrackBall"
      MatchProduct "ELECOM TrackBall Mouse HUGE TrackBall"
      Driver "evdev"
      Option "ButtonMapping" "10 11 3 4 5 6 7 2 1 9 8 12"
      Option "EmulateWheel" "1"
      Option "EmulateWheelButton" "1"
      Option "EmulateWheelInertia" "5"
      Option "Device Accel Profile" "-1"
      Option "XAxisMapping" "6 7"
      Option "YAxisMapping" "4 5"
    ''
    ''
      Identifier "Clearly Superior Trackball"
      MatchProduct "Clearly Superior Technologies. CST Laser Trackball"
      Driver "evdev"
      Option "EmulateWheel" "1"
      Option "Device Accel Profile" "-1"
      Option "XAxisMapping" "6 7
      Option "YAxisMapping" "9 10"
      Option "EmulateWheelInertia" "5"
    ''
    ''
      Identifier "Logitech M570"
      MatchProduct "Logitech M570"
      Driver "evdev"
      Option "ButtonMapping" "1 9 3 4 5 6 7 2 8"
      Option "EmulateWheel" "1"
      Option "EmulateWheelButton" "8"
      Option "XAxisMapping" "6 7"
      Option "YAxisMapping" "4 5"
    '' ];
  };
}
