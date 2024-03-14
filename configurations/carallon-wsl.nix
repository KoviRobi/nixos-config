# vim: set ts=2 sts=2 sw=2 et :
{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./base-configuration.nix
      ./carallon.nix
      ../modules/graphical.nix
      (import ../modules/default-user.nix { })
      ../modules/ssh.nix
    ];

  services.openssh.ports = [ 22 2233 ];

  systemd.user.services.pulseaudio.enable = false;
  hardware.pulseaudio.extraClientConf = ''
    default-server = _gateway;
  '';

  programs.atop.netatop.enable = lib.mkForce false;

  services.xserver.enable = lib.mkForce false;
  services.xserver.displayManager.lightdm.enable = lib.mkForce false;
  services.xserver.windowManager.i3.enable = lib.mkForce false;

  virtualisation.podman.enable = true;
  virtualisation.podman.dockerCompat = true;
}
