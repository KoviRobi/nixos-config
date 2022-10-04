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

  libnotify
  xdotool
  xclip
  xorg.xev
  xorg.xkbprint
  xorg.xkbutils
  xorg.xmodmap
  xorg.xhost
] ++
lib.optionals (pkgs.buildPlatform == pkgs.hostPlatform) [
  mpv
  flameshot
  signal-desktop
  v4l-utils
]
