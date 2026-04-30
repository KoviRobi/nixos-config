{
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  nixpkgs.config.allowUnfree = true;
  hardware = {
    enableAllFirmware = true;
    deviceTree = {
      enable = true;
      name = "qcom/x1e80100-dell-inspiron-14-plus-7441.dtb";
    };
  };
  powerManagement = {
    enable = true;
    powertop.enable = true;
  };
  environment.systemPackages = [ pkgs.powertop ];
  boot = {
    initrd.availableKernelModules = [
      "hid"
      "hid_generic"
      "hid_multitouch"
      "i2c_hid_of"
      "i2c_qcom_geni"
      "nvme"
      "nvmem_qcom_spmi_sdam"
      "phy_qcom_qmp_pcie"
    ];
    initrd.kernelModules = [ ];
    kernelPackages = pkgs.linuxPackages_testing;
    kernelModules = [ ];
    kernelParams = [
      "clk_ignore_unused"
      "pd_ignore_unused"
      "cma=128M"
      "boot.shell_on_fail"
    ];
    extraModulePackages = [ ];
    loader = {
      efi.efiSysMountPoint = "/boot/efi/";
      systemd-boot.enable = true;
    };
  };

  systemd.tpm2.enable = false;

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/04552ac9-c6b6-4159-a612-8701ddc18d4d";
    fsType = "btrfs";
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/A4A6-EBA4";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  services = {
    upower.ignoreLid = true;
    logind.settings.Login.HandleLidSwitch = "ignore";
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

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
  system.stateVersion = "25.11"; # Did you read the comment?
  home-manager.users.default-user.home.stateVersion = "25.11";
  home-manager.users.root.home.stateVersion = "25.11";
}
