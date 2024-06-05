{ config, lib, pkgs, modulesPath, ... }:

{
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
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  boot.initrd.luks.devices."nixos-flash".device = "/dev/disk/by-uuid/4430fbb2-085c-4470-bd88-648a21d75415";

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/90e4f594-2747-4198-b915-1a212e997762";
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
  home-manager.users.root.home.stateVersion = "23.05";
}
