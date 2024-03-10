# vim: set ts=2 sts=2 sw=2 et :
{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./base-configuration.nix
      ../modules/graphical.nix
      (import ../modules/default-user.nix { })
      ../modules/ssh.nix
    ];

  systemd.user.services.pulseaudio.enable = false;
  hardware.pulseaudio.extraClientConf = ''
    default-server = _gateway;
  '';
}
