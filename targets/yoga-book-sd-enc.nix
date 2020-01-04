{ config, lib, pkgs, ... }:

{
  networking.hostName = "C930-sd";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "usbhid" "uas" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # Include lots of firmware.
  # For iwlwifi for 01:00.0 Network controller:
  #     Intel Corporation Wireless 8265 / 8275 (rev 78)  ?
  hardware.enableRedistributableFirmware = true;

  boot.initrd.luks.devices."nixos-sd".device = "/dev/disk/by-uuid/f3619352-91f1-44da-b6fd-83af7bcf150d";

  fileSystems."/" =
  { device = "/dev/disk/by-uuid/4d2f1de5-fe34-49e6-9b87-8e6e78e59d01";
    fsType = "f2fs";
  };

  fileSystems."/boot" =
  { device = "/dev/disk/by-uuid/1C4E-ADD9";
    fsType = "vfat";
  };

  nix.maxJobs = lib.mkDefault 4;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?
}
