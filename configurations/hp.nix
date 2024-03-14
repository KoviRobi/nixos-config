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

  nix.settings.trusted-substituters = map
    (address:
      "ssh://nix-ssh@${address}"
      + "?trusted=1"
      + "&compress=1"
      + "&ssh-key=/root/.ssh/nix-store-ed25519"
      + "&base64-ssh-public-host-key="
      + "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUUxQkVQUkFHOEdidDQyYmZRWEpG"
      + "ei9sNFdsdEU1Y0JBSVBQZzhOeTZ6VXMgcm9vdEBwYy1uaXhvcy1hCg==")
    [ "192.168.0.29" "pc-nixos-a.badger-toad.ts.net" ];

  virtualisation.docker.enable = true;
  users.users.default-user.extraGroups = [ "scanner" "lp" "docker" "libvirtd" ];

  virtualisation.libvirtd.enable = true;

  solarized.brightness = "light";

  nixpkgs.config.allowUnfree = true; # For google chrome (for DRM :( )
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "ehci_pci" "usbhid" "sd_mod" "sdhci_pci" ];
  boot.kernelModules = [ "kvm-amd" ];

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  networking.networkmanager.appendNameservers = [ "127.0.0.53" "1.1.1.1" "1.1.0.0" ];

  services.xserver.dpi = 109;
  hardware.opengl.driSupport32Bit = true;

  environment.systemPackages = [
    pkgs.docker-credential-helpers
    pkgs.virt-manager
    (pkgs.writeShellScriptBin "rewin" ''sudo bootctl set-oneshot auto-windows; reboot'')
  ]
  ++ (import ../packages/pc.nix args)
  ++ (import ../packages/pc-unfree.nix args);

  nix.settings.secret-key-files = "/etc/secrets/nix/secret-key";
}
