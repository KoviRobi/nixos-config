{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  services = {
    libinput.enable = false;
    xserver = {
      synaptics = {
        enable = true;
        tapButtons = false;
        vertTwoFingerScroll = true;
        horizTwoFingerScroll = true;
        palmDetect = true;
        palmMinWidth = 7;
        palmMinZ = 25;
      };
    };
    auto-cpufreq.enable = true;
  };

  powerManagement.enable = true;
  powerManagement.powertop.enable = true;

  environment.systemPackages = [ pkgs.powertop ];

  boot = {
    initrd = {
      availableKernelModules = [
        "ehci_pci"
        "ata_piix"
        "xhci_pci"
        "sd_mod"
        "sr_mod"
        "sdhci_pci"
      ];
      kernelModules = [ ];

      luks.devices."acer-nixos-a".device = "/dev/disk/by-uuid/ed308956-0c94-4cd2-a8a5-9e6aa9ff22f8";
    };
    kernelModules = [
      "kvm-intel"
      "wl"
    ];
    extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];

    loader.grub.enable = true;
    loader.grub.device = "/dev/disk/by-id/ata-Samsung_SSD_840_EVO_1TB_S1D9NSAF319989A";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
  home-manager.users.default-user.home.stateVersion = "23.05";
  home-manager.users.root.home.stateVersion = "23.05";

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/fcd1faed-c003-4472-a4ac-02dc2b8f8d61";
    fsType = "xfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/30C3-618E";
    fsType = "vfat";
  };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp2s0f0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp3s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
