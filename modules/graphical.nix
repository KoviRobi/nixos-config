# vim: set ts=2 sts=2 sw=2 et :
{
  pkgs,
  lib,
  ...
}:

{
  fonts.enableDefaultPackages = true;
  fonts.packages = with pkgs; [
    noto-fonts
    dejavu_fonts
    liberation_ttf
    lmodern
    nerd-fonts.dejavu-sans-mono
    nerd-fonts.caskaydia-cove
    inconsolata
  ];

  imports = [ ../packages/desktop-environment.nix ];

  programs = {
    regreet = {
      enable = true;
      theme = {
        package = pkgs.gruvbox-dark-gtk;
        name = "gruvbox-dark";
      };
      iconTheme = {
        package = pkgs.gruvbox-dark-icons-gtk;
        name = "oomox-gruvbox-dark";
      };
      cursorTheme = {
        package = pkgs.capitaine-cursors-themed;
        name = "Capitaine Cursors (Gruvbox)";
      };
      settings = {
        GTK = {
          application_prefer_dark_theme = true;
        };
      };
      cageArgs = [
        "-s"
        "-m"
        "last"
      ];
    };
    sway.enable = true;
    foot = {
      enable = true;
      theme = "gruvbox";
      settings = {
        main = {
          font = "CaskaydiaCove Nerd Font Mono:size=10";
        };
      };
    };
  };

  xdg.portal = {
    enable = true;
    wlr = {
      enable = true;
      settings = {
        screencast = {
          max_fps = 30;
          exec_before = "${lib.getExe' pkgs.dunst "dunstctl"} set-paused true";
          exec_after = "${lib.getExe' pkgs.dunst "dunstctl"} set-paused false";
          chooser_type = "simple";
          chooser_cmd = "${lib.getExe pkgs.slurp} -f 'Monitor: %o' -or";
        };
      };
    };
  };

  services = {
    displayManager.sessionPackages = [
      (
        pkgs.writeTextFile {
          name = "startx-xsession";
          destination = "/share/xsessions/startx.desktop";
          # Desktop Entry Specification:
          # - https://standards.freedesktop.org/desktop-entry-spec/latest/
          # - https://standards.freedesktop.org/desktop-entry-spec/latest/ar01s06.html
          text = ''
            [Desktop Entry]
            Version=1.0
            Type=XSession
            Name=startx
            Exec=$HOME/.xsession
            DesktopNames=startx
            Comment=Plain startx
          '';
        }
        // {
          providedSessions = [ "startx" ];
        }
      )
    ];

    udisks2.enable = true;
    greetd.enable = true;
    xserver = {
      enable = true;
      xkb = {
        layout = "us";
        options = "compose:ralt";
      };
      displayManager.startx.enable = true;
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
  };
}
