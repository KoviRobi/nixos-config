{ pkgs, lib, config, ... }:
{
  programs.wireshark.enable = true;
  programs.wireshark.package = pkgs.wireshark-qt;

  programs.firefox.enable = true;
  programs.firefox.nativeMessagingHosts.packages = [ pkgs.ff2mpv pkgs.passff-host ];

  programs.noisetorch.enable = true;

  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    hicolor-icon-theme

    gparted
    seahorse
    udiskie
    geeqie

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
  ] ++
  lib.optionals (pkgs.buildPlatform == pkgs.hostPlatform) [
    (mpv.override {
      scripts = with mpvScripts; [ autosubsync-mpv uosc mpris ];
    })
    flameshot
    signal-desktop
    v4l-utils
  ];
}
