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
      geeqie
      pinentry-gnome3

      libreoffice

      pamixer
      paprefs
      pavucontrol

      playerctl

      mupdf
      zathura
      st
      st.terminfo
      ffmpeg

      x11vnc
      tigervnc

      libnotify
      xdotool
      xsel
      xorg.xev
      xorg.xkbprint
      xorg.xkbutils
      xorg.xmodmap
      xorg.xhost

      imagemagick

      alass # subtitle sync

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
          autosubsync-mpv
          uosc
          mpris
        ];
      })
      flameshot
      signal-desktop
      v4l-utils
    ];
}
