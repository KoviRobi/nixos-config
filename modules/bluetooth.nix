# vim: set ts=2 sts=2 sw=2 et :
{ config, pkgs, ... }:

{
  services.blueman.enable = true;
  hardware.pulseaudio.extraModules = with pkgs; [ pulseaudio-modules-bt ];
  hardware.pulseaudio.extraConfig = "load-module module-bluetooth-discover";
} //
(
  {
    home-manager.users.default-user.services.blueman-applet.enable = true;
  }
)
