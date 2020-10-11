{ config, lib, ... }:
{
  config.systemd.user.services.parcellite.Service.Restart = lib.mkForce "on-failure";
  config.systemd.user.services.parcellite.Service.RestartSec = "10s";
  config.systemd.user.services.network-manager-applet.Service.Restart = "on-failure";
  config.systemd.user.services.network-manager-applet.Service.RestartSec = "10s";
  config.systemd.user.services.pasystray.Service.Restart = "on-failure";
  config.systemd.user.services.pasystray.Service.RestartSec = "10s";
}
