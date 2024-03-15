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
      ../modules/initrd-ssh.nix
    ];

  boot.initrd.network.flushBeforeStage2 = false;
  initrd-ssh.interface = "enp0s31f6";
  initrd-ssh.udhcpcExtraArgs = [ "-t 10" "-b" ];
  systemd.targets.emergency.wants = [ "sshd.service" ];

  solarized.brightness = "light";

  services.xserver.dpi = 93;

  virtualisation.podman.enable = true;
  virtualisation.podman.dockerCompat = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.qemu.ovmf.packages = [ pkgs.OVMFFull.fd ];
  users.users.default-user.extraGroups = [ "scanner" "lp" "docker" "libvirtd" ];

  environment.systemPackages = with pkgs; [ virt-manager ];
}
