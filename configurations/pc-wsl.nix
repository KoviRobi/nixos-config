# vim: set ts=2 sts=2 sw=2 et :
{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./base-configuration.nix
      ../modules/graphical.nix
      (import ../modules/default-user.nix {
        name = "rmk";
        user-options = { uid = 1000; };
        group-options = { gid = 1000; };
      })
      ../modules/ssh.nix
    ];

  systemd.user.services.pulseaudio.enable = false;
  hardware.pulseaudio.extraClientConf = ''
    default-server = _gateway;
  '';
}
