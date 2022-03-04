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

  boot.initrd.luks.devices."nixos-sd-128GiB".device = "/dev/disk/by-uuid/d5f8f372-a236-41be-9769-72196afdbba6";

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/9b9fe817-450c-45e2-90a4-be8fbb967aad";
      fsType = "f2fs";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/1C4E-ADD9";
      fsType = "vfat";
    };

  nix.settings.max-jobs = lib.mkDefault 4;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.09"; # Did you read the comment?
}
