{
  pkgs,
  lib,
  ...
}:
{
  programs = {
    wireshark = {
      enable = true;
      package = pkgs.wireshark;
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
      gruvbox-dark-icons-gtk
      capitaine-cursors-themed

      meld # diff tool

      gparted
      seahorse
      udiskie
      pinentry-gnome3

      libreoffice

      # Offline net
      kiwix
      kiwix-tools

      # Wayland helpers
      slurp
      grim
      foot
      foot.themes
      waybar

      pamixer
      paprefs
      pavucontrol

      playerctl

      # Small games
      pysolfc

      # VM
      virt-manager
      virtiofsd
      spice-gtk # For USB redirection
      swtpm

      # Docker tools
      dive
      docker
      docker-credential-helpers
      skopeo

      mupdf
      st
      st.terminfo
      sioyek
      zathura
      ffmpeg
      rofi

      # Drag and drop helper for terminal users
      dragon-drop

      wayvnc
      wlvncc

      libnotify
      xdotool
      xsel
      xev
      xhost
      xkbprint
      xkbutils
      xmodmap
      xprop
      xwininfo

      wlr-randr
      wlprop
      wl-clipboard
      wofi

      imagemagick
      inkscape
      gimp

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
          autosubsync-mpv
          mpris
          thumbfast
          uosc
          visualizer
        ];
      })
      flameshot
      v4l-utils
    ];
}
