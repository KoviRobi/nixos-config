{ lib, ... }:
{
  config.systemd.user.services = {
    parcellite.Service.Restart = lib.mkForce "on-failure";
    parcellite.Service.RestartSec = "10s";
    network-manager-applet.Service.Restart = "on-failure";
    network-manager-applet.Service.RestartSec = "10s";
    pasystray.Service.Restart = "on-failure";
    pasystray.Service.RestartSec = "10s";
  };
}
