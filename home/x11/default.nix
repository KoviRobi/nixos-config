{
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./i3
    ./picom.nix
    ./restart-on-failure.nix
    ./ghostty.nix
    ./wezterm.nix
    ./ringboard.nix
    "${
      fetchTarball {
        url = "https://github.com/KoviRobi/feh-random-background/archive/80bc3616bb8fc87225d1447431555230a4bf3b12.tar.gz";
        name = "feh-random-background";
        sha256 = "1hnwv33wmiaabkv7yqg6khc1aqrp01g2yv5l76bc47d80cj0amad";
      }
    }/home-manager-service.nix"
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
        "reload-background" = "$HOME/.cache/fehbg || true";
      };
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
    config.common = {
      default = "gtk";
      "org.freedesktop.impl.portal.Settings" = "darkman";
    };
  };

  services = {
    network-manager-applet.enable = true;
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
      settings = {
        lat = 51.477;
        lng = 0.0;
      };
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
  home.pointerCursor = {
    size = builtins.div config.nixos.services.xserver.dpi 5;
  };
  gtk.theme = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
  };
}
