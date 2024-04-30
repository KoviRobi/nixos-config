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

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "saleae-logic-2"
    "saleae-logic"
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

  environment.systemPackages = with pkgs; [ virt-manager saleae-logic-2 ];
  services.udev.packages = with pkgs; [ saleae-logic-2 ];

  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplip ];
}
