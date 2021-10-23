{ pkgs, lib, config, ... }:
with pkgs;
[
  gnome3.adwaita-icon-theme
  hicolor-icon-theme

  gparted
  gnome3.seahorse
  udiskie
  geeqie

  audacity
  easytag
  gmpc
  libreoffice
  inkscape

  firefox

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
lib.optionals (lib.matchAttrs { allowUnfree = true; } config.nixpkgs.config) [
  google-chrome
  steam
] ++
lib.optionals (pkgs.buildPlatform == pkgs.hostPlatform) [
  cura
  mpv
  flameshot
  antimicroX
  signal-desktop
  v4l-utils
]
