# vim: set ts=2 sts=2 sw=2 et :
{ config, pkgs, ... }:

{ services.blueman.enable = true;
  home-manager.users.rmk35.services.blueman-applet.enable = true;
  hardware.pulseaudio.extraModules = with pkgs; [ pulseaudio-modules-bt ];
  hardware.pulseaudio.extraConfig = "load-module module-bluetooth-discover";
}
