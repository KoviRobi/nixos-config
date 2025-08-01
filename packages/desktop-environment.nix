{
  pkgs,
  lib,
  ...
}:
{
  programs = {
    wireshark.enable = true;
    wireshark.package = pkgs.wireshark-qt;

    firefox.enable = true;
    firefox.nativeMessagingHosts.packages = [
      pkgs.ff2mpv
      (pkgs.passff-host.override {
        pass = pkgs.pass.withExtensions (exts: with exts; [ pass-otp ]);
      })
    ];

    noisetorch.enable = true;
  };

  environment.systemPackages =
    with pkgs;
    [
      adwaita-icon-theme
      hicolor-icon-theme

      gparted
      seahorse
      udiskie
      pinentry-gnome3

      libreoffice

      pamixer
      paprefs
      pavucontrol

      playerctl

      mupdf
      zathura
      ffmpeg
      rofi

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
      xorg.xkbprint
      xorg.xkbutils
      xorg.xmodmap
      xorg.xhost

      imagemagick

      xscopes-qt

      typst
      typst-live
      tinymist
      typstyle
      typst-fmt
      prettypst
      pandoc
    ]
    ++ lib.optionals (pkgs.buildPlatform == pkgs.hostPlatform) [
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
      signal-desktop
      v4l-utils
    ];
}
