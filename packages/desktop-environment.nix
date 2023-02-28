{ pkgs, lib, config, ... }:
with pkgs;
[
  gnome.adwaita-icon-theme
  hicolor-icon-theme

  gparted
  gnome.seahorse
  udiskie
  geeqie

  gmpc
  libreoffice

  firefox
  chromium

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

  input-leap
] ++
lib.optionals (pkgs.buildPlatform == pkgs.hostPlatform) [
  mpv
  flameshot
  signal-desktop
  v4l-utils
]
