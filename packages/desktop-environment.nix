{ pkgs, lib, config, ... }:
{
  programs.wireshark.enable = true;
  programs.wireshark.package = pkgs.wireshark-qt;

  programs.firefox.enable = true;
  programs.firefox.nativeMessagingHosts.packages = [ pkgs.ff2mpv pkgs.passff-host ];

  programs.noisetorch.enable = true;

  environment.systemPackages = with pkgs; [
    gnome.adwaita-icon-theme
    hicolor-icon-theme

    gparted
    gnome.seahorse
    udiskie
    geeqie

    gmpc
    libreoffice

    pamixer
    paprefs
    pavucontrol

    zathura
    st
    ffmpeg

    x11vnc
    tigervnc

    libnotify
    xdotool
    xclip
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
      scripts = with mpvScripts; [ autosubsync-mpv uosc ];
    })
    flameshot
    signal-desktop
    v4l-utils
  ];
}
