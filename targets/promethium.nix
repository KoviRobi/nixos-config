# vim: set ts=2 sts=2 sw=2 et :
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/71e4ac16-e84d-46c8-a54a-a71ea985cedf";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."promethium-nixos-a".device = "/dev/disk/by-uuid/016f7bcf-f269-4e4a-90b9-43c246f7827d";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/E266-D07D";
      fsType = "vfat";
      options = [ "umask=0077" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/ac3f700c-2807-4765-8cb9-e5feadb8e307"; }
    ];

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?
  home-manager.users.default-user.home.stateVersion = "23.11";
  home-manager.users.root.home.stateVersion = "23.11";
}
