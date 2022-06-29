{ config, lib, pkgs, modulesPath, ... }:

{
  networking.hostName = "C930-flash";

  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "usbhid" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # Include lots of firmware.
  # For iwlwifi for 01:00.0 Network controller:
  #     Intel Corporation Wireless 8265 / 8275 (rev 78)  ?
  hardware.enableRedistributableFirmware = true;

  boot.initrd.luks.devices."nixos-flash".device = "/dev/disk/by-uuid/c51fecec-e8e9-40ba-9062-2740b9d84d06";

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/860298a3-1049-45c2-82f9-00d29b067f00";
      fsType = "f2fs";
    };

  swapDevices = [ ];

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/1C4E-ADD9";
      fsType = "vfat";
    };

  nix.settings.max-jobs = lib.mkDefault 4;

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
  home-manager.users.default-user.home.stateVersion = "18.09";
}
