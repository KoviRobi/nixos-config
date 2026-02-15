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
        invert = br: if br == "light" then "dark" else "light";
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
          x11 = ''
            ${lib.getExe' pkgs.coreutils "cat"} <<EOF | ${lib.getExe pkgs.xrdb} -merge
              *.bg0_hard: ${xprop "${brightness}0_hard"}
              *.bg0:      ${xprop "${brightness}0"}
              *.bg0_soft: ${xprop "${brightness}0_soft"}
              *.bg1:      ${xprop "${brightness}1"}
              *.bg2:      ${xprop "${brightness}2"}
              *.bg3:      ${xprop "${brightness}3"}
              *.bg4:      ${xprop "${brightness}4"}

              *.fg0_hard: ${xprop "${invert brightness}0_hard"}
              *.fg0:      ${xprop "${invert brightness}0"}
              *.fg0_soft: ${xprop "${invert brightness}0_soft"}
              *.fg1:      ${xprop "${invert brightness}1"}
              *.fg2:      ${xprop "${invert brightness}2"}
              *.fg3:      ${xprop "${invert brightness}3"}
              *.fg4:      ${xprop "${invert brightness}4"}
            EOF
            systemctl --user restart pasystray.service
            ${pkgs.i3}/bin/i3-msg reload
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
  home = {
    sessionVariables = {
      TERMINAL = lib.getExe pkgs.wezterm;
    };
    pointerCursor = {
      size = builtins.div config.nixos.services.xserver.dpi 5;
    };
  };
  gtk.theme = {
    name = "Gruvbox dark";
    package = pkgs.gruvbox-dark-icons-gtk;
  };
}
