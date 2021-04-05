{ pkgs, lib, config, ... }:
with pkgs;
[
  gnome3.adwaita-icon-theme
  hicolor-icon-theme

  antimicroX

  gparted
  gnome3.seahorse
  udiskie
  scrot

  cura
  audacity
  easytag
  gmpc
  libreoffice
  inkscape

  firefox
  signal-desktop
  v4l-utils

  pamixer
  paprefs
  pavucontrol

  xdotool
  xorg.xev
  xorg.xmodmap
  xorg.xhost
] ++
lib.optionals (lib.matchAttrs { allowUnfree = true; } config.nixpkgs.config) [
  google-chrome
  steam
]
