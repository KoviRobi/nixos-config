{ config, lib, pkgs, ... }:

{
  networking.hostName = "C930-sd";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "usbhid" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # Include lots of firmware.
  # For iwlwifi for 01:00.0 Network controller:
  #     Intel Corporation Wireless 8265 / 8275 (rev 78)  ?
  hardware.enableRedistributableFirmware = true;

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/b6eb23a1-3c46-4074-99cd-d0b401a0fa54";
      fsType = "xfs";
    };

  # fileSystems."/boot" =
  #   { device = "/dev/disk/by-uuid/FFBC-17D9";
  #     fsType = "vfat";
  #   };
  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/1C4E-ADD9";
      fsType = "vfat";
    };

  nix.maxJobs = lib.mkDefault 4;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
