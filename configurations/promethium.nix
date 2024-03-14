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
      ../modules/graphical.nix
    ];

  solarized.brightness = "light";

  services.xserver.dpi = 93;

  virtualisation.podman.enable = true;
  virtualisation.podman.dockerCompat = true;
  virtualisation.libvirtd.enable = true;
  users.users.default-user.extraGroups = [ "scanner" "lp" "docker" "libvirtd" ];

  environment.systemPackages = with pkgs; [ virt-manager ];
}
