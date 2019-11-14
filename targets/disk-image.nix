# nix build -f '<nixpkgs/nixos>' config.system.build.diskImage -I nixos-config=disk-image.nix
{ config, lib, pkgs, ... }:

with lib;
{
  config = {
    system.build.diskImage = import <nixpkgs/nixos/lib/make-disk-image.nix> {
      name = "nixos-pendrive-image-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}";

      inherit pkgs lib config;
      partitionTableType = "legacy";
      diskSize = 7 * 1000; # 7 storage manufacturer Gigabytes
      format = "raw";
    };

    fileSystems."/" = {
      device = "/dev/disk/by-label/nixos";
      autoResize = true;
      fsType = "ext4";
    };

    boot.growPartition = true;
    boot.loader.grub.device = "/dev/sda";

  };
}
