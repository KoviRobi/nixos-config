{
  pkgs,
  lib,
  ...
}:
{
  programs = {
    wireshark = {
      enable = true;
      package = pkgs.wireshark-qt;
      dumpcap.enable = true;
    };

    noisetorch.enable = true;
  };

  users.users.default-user.extraGroups = [ "wireshark" ];

  xdg.icons.fallbackCursorThemes = [ "Capitaine Cursors (Gruvbox)" ];

  environment.systemPackages =
    with pkgs;
    [
      adwaita-icon-theme
      hicolor-icon-theme
      capitaine-cursors-themed

      gparted
      seahorse
      udiskie
      pinentry-gnome3

      libreoffice

      # Offline net
      kiwix
      kiwix-tools

      pamixer
      paprefs
      pavucontrol

      playerctl

      mupdf
      st
      st.terminfo
      zathura
      ffmpeg
      rofi

      # Drag and drop helper for terminal users
      dragon-drop

      x11vnc
      tigervnc
      (pkgs.writeShellScriptBin "shareX11" ''
        cat <<EOF
        Note, this is not secure (e.g. password visible in /proc, as well as
        stdout here). Don't use it with an open port, use it over e.g. SSH

        EOF
        PASSWD=$(</dev/random tr -dc '[:print:]' | head -c8)
        echo "$PASSWD"
        ARGS=("''${@}")
        if [ ''${#ARGS} -eq 0 ]; then
          ARGS=(-q -xinerama -clip xinerama0)
        fi
        DISPLAY=:0 x11vnc -passwd "''$PASSWD" "''${ARGS[@]}"
      '')

      libnotify
      xdotool
      xsel
      xorg.xev
      xorg.xhost
      xorg.xkbprint
      xorg.xkbutils
      xorg.xmodmap
      xorg.xprop
      xorg.xwininfo

      imagemagick

      typst
      typst-live
      tinymist
      typstyle
      prettypst
      pandoc
    ]
    ++ lib.optionals (pkgs.stdenv.buildPlatform == pkgs.stdenv.hostPlatform) [
      (mpv.override {
        scripts = with mpvScripts; [
          ## TODO:
          ##┃        … while evaluating attribute 'propagatedBuildInputs' of derivation 'ffsubsync-0.4.29'
          ## ...
          ##┃        error: future-1.0.0 not supported for interpreter python3.13
          ## https://github.com/NixOS/nixpkgs/pull/418968
          # autosubsync-mpv
          uosc
          mpris
        ];
      })
      flameshot
      v4l-utils
    ];
}
