# vim: set ts=2 sts=2 sw=2 et :
{ config, lib, pkgs, ... }@args:

{
  imports =
    [
      ./base-configuration.nix
      (import ../modules/default-user.nix { })
      ../modules/ssh.nix
      ../modules/graphical.nix
      (import ../modules/avahi.nix { publish = true; })
    ];

  environment.systemPackages = import ../packages/desktop-environment.nix args;

  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPorts = [ ];

  security.pam.services.login.fprintAuth = true;
}
