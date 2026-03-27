{
  pkgs,
  lib,
  config,
  ...
}:
let
  xprop = name: config.xresources.properties."*.${name}";
in
{
  imports = [
    ./i3
    ./restart-on-failure.nix
    ./ghostty.nix
    ./ringboard.nix
  ];

  programs = {
    librewolf = {
      enable = true;
      nativeMessagingHosts = [
        pkgs.ff2mpv
        (pkgs.passff-host.override {
          pass = pkgs.pass.withExtensions (exts: with exts; [ pass-otp ]);
        })
      ];
    };
    autorandr = {
      enable = true;
      hooks.postswitch = {
        "reload-background" = "$HOME/.local/share/feh-random-background/current || true";
      };
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-termfilechooser
    ];
    config.common = {
      default = "gtk";
      "org.freedesktop.impl.portal.Settings" = "darkman";
      "org.freedesktop.impl.portal.FileChooser" = "termfilechooser";
      "org.freedesktop.impl.portal.ScreenCast" = "wlr";
      "org.freedesktop.impl.portal.Screenshot" = "wlr";

    };
  };

  services = {
    network-manager-applet.enable = true;
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
      settings = {
        lat = 51.477;
        lng = 0.0;
      };
    }
    // (
      let
        f = brightness: {
          state-file = "echo '${brightness}' > ~/.local/state/brightness";
          foot = ''
            echo 'initial-color-theme=${brightness}' > ~/.config/foot/brightness.ini
            ${pkgs.procps}/bin/pkill ${if brightness == "dark" then "-USR1" else "-USR2"} foot
          '';
          waybar = ''
            echo '@import url("${brightness}.css");' > ~/.config/waybar/brightness.css
          '';
          kakoune = ''
            ${pkgs.kakoune}/bin/kak -l | while read sid; do
              (
                echo "colorscheme gruvbox-${brightness}"
                echo 'face global Information MenuBackground'
              ) | ${pkgs.kakoune}/bin/kak -p $sid
            done
          '';
          tmux = ''
            TMUX_TMPDIR=/run/user/$UID \
            ${pkgs.tmux}/bin/tmux source-file \
                ${pkgs.tmux-gruvbox-v1}/share/tmux-plugins/gruvbox/tmux-gruvbox-${brightness}.conf
          '';
          sway = ''
            cd ~/.config/sway
            ${pkgs.coreutils}/bin/ln -sf ${brightness}.conf brightness.conf
            ${pkgs.sway}/bin/swaymsg reload
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
      interval = "1h";
      command = [
        (lib.getExe' pkgs.sway "swaymsg")
        "\"output '*' bg \'$(printf '%%q' \"$BGFILE\")\' fit\""
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
  home = {
    sessionVariables = {
      TERMINAL = lib.getExe pkgs.foot;
    };
    pointerCursor = {
      size = builtins.div config.nixos.services.xserver.dpi 5;
    };
    file.".config/xdg-desktop-portal-termfilechooser/config".text = ''
      [filechooser]
      cmd=${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/nnn-wrapper.sh
      env=TERMCMD=foot
           EDITOR=kak
    '';
  };
  gtk.theme = {
    name = "Gruvbox dark";
    package = pkgs.gruvbox-dark-icons-gtk;
  };
}
