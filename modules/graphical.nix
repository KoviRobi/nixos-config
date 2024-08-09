# vim: set ts=2 sts=2 sw=2 et :
{ config, pkgs, lib, ... }:

{
  fonts.enableDefaultPackages = true;
  fonts.packages = with pkgs; [
    noto-fonts
    dejavu_fonts
    liberation_ttf
    lmodern
    terminus-nerdfont
    inconsolata
  ];

  imports = [ ../packages/desktop-environment.nix ];

  services.udisks2.enable = true;

  services.displayManager = {
    defaultSession = "none+i3";
    autoLogin = { enable = true; user = config.users.users.default-user.name; };
  };
  services.xserver =
    {
      enable = true;
      xkb.layout = "us";
      displayManager = {
        lightdm = {
          enable = true;
          greeters.gtk.cursorTheme.package = pkgs.adwaita-icon-theme;
          greeters.gtk.cursorTheme.name = "Adwaita";
        };
      };
      windowManager.i3.enable = true;
      exportConfiguration = true;
      inputClassSections = [
        ''
          Identifier "Kensington SlimBlade"
          MatchProduct "Kensington Kensington Slimblade Trackball"
          Driver "evdev"
          Option "ButtonMapping" "1 10 3 4 5 6 7 2 9 10 11 12"
          Option "EmulateWheel" "1"
          Option "EmulateWheelButton" "2"
          Option "XAxisMapping" "6 7
          Option "YAxisMapping" "4 5"
          Option "EmulateWheelInertia" "5"
          Option "Device Accel Profile" "-1"
        ''
        ''
          Identifier "ELECOM HUGE TrackBall"
          MatchProduct "ELECOM TrackBall Mouse HUGE TrackBall"
          Driver "evdev"
          Option "EmulateWheel" "1"
          Option "EmulateWheelButton" "9"
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
        ''
        ''
          Identifier "3Dconnexion  SpacePilot PRO "
          MatchProduct "3Dconnexion  SpacePilot PRO "
          Driver "evdev"
          Option "Ignore" "on"
        ''
      ];
    };
}
