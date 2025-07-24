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

  nixpkgs.config.allowUnfree = true;
  hardware = {
    enableAllFirmware = true;
    deviceTree = {
      enable = true;
      name = "qcom/x1e80100-dell-inspiron-14-plus-7441.dtb";
    };
  };
  boot = {
    initrd.availableKernelModules = [
      "hid"
      "hid_generic"
      "hid_multitouch"
      "i2c_hid_of"
      "i2c_qcom_geni"
      "nvme"
      "nvmem_qcom_spmi_sdam"
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
    kernelPatches =
      let
        dir = ../patches/linux;
        contents = builtins.readDir dir;
        files = builtins.filter (name: contents.${name} == "regular") (builtins.attrNames contents);
      in
      [
        {
          name = "dell-inspiron-7441-config";
          patch = null;
          extraConfig = ''
            TYPEC y
            PHY_QCOM_QMP y
            QCOM_CLK_RPM y
            MFD_QCOM_RPM y
            REGULATOR_QCOM_RPM y
            PHY_QCOM_QMP_PCIE y
            CLK_X1E80100_CAMCC y
          '';
        }
      ]
      ++ map (name: {
        inherit name;
        patch = /${dir}/${name};
      }) files;
    extraModulePackages = [ ];
    loader = {
      efi.efiSysMountPoint = "/boot/efi/";
      systemd-boot.enable = true;
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/fa97187a-701c-4293-b9e9-8a429097864b";
    fsType = "ext4";
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/A4A6-EBA4";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  swapDevices = [ ];

  services.fprintd.enable = true;

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
