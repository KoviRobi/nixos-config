# vim: set ts=2 sts=2 sw=2 et :
{ config, pkgs, ... }:

{
  hardware.bluetooth.enable = true;
  environment.systemPackages = [ pkgs.blueman ];
  services.dbus.packages = [ pkgs.blueman ];
}
// {
  home-manager.users.default-user.services.blueman-applet.enable = true;
}
