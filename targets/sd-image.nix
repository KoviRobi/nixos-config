# nix build -f '<nixpkgs/nixos>' config.system.build.sdImage -I nixos-config=sd-image.nix
{
  config,
  pkgs,
  lib,
  ...
}:
let
  mypkgs = import ./pkgs/all-packages.nix { nixpkgs = pkgs; };
  extlinux-conf-builder =
    import
      <nixpkgs/nixos/modules/system/boot/loader/generic-extlinux-compatible/extlinux-conf-builder.nix>
      {
        pkgs = pkgs.buildPackages;
      };
in
{
  imports = [
    ./base-configuration.nix
    <nixpkgs/nixos/modules/installer/cd-dvd/sd-image.nix>
  ];

  boot = {
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;

      # Use the systemd-boot EFI boot loader.
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    consoleLogLevel = lib.mkDefault 7;

    extraModulePackages = [ mypkgs.linuxPackages.yogabook-c930-eink-driver ];
  };

  sdImage = {
    populateFirmwareCommands = "";
    populateRootCommands = ''
      mkdir -p ./files/boot
      ${extlinux-conf-builder} -t 3 -c ${config.system.build.toplevel} -d ./files/boot
    '';
  };

  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPorts = [ ];
}
