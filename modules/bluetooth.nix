# vim: set ts=2 sts=2 sw=2 et :
{ config, pkgs, ... }:

{
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
}
// {
  home-manager.users.default-user.services.blueman-applet.enable = true;
}
