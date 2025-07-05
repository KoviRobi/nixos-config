{
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./i3
    ./restart-on-failure.nix
    ./ghostty.nix
    "${
      fetchTarball {
        url = "https://github.com/KoviRobi/feh-random-background/archive/80bc3616bb8fc87225d1447431555230a4bf3b12.tar.gz";
        name = "feh-random-background";
        sha256 = "1hnwv33wmiaabkv7yqg6khc1aqrp01g2yv5l76bc47d80cj0amad";
      }
    }/home-manager-service.nix"
  ];

  programs.librewolf = {
    enable = true;
    nativeMessagingHosts = [
      pkgs.ff2mpv
      (pkgs.passff-host.override {
        pass = pkgs.pass.withExtensions (exts: with exts; [ pass-otp ]);
      })
    ];
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "gtk";
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
              echo "colorscheme gruvbox-${brightness}" | \
                  ${pkgs.kakoune}/bin/kak -p $sid
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
  home.pointerCursor = {
    size = builtins.div config.nixos.services.xserver.dpi 5;
  };
  gtk.theme = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
  };
}
