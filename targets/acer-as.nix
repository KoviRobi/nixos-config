{ config, pkgs, ... }:
{
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "nodev"; # or "nodev" for efi only

  networking.hostName = "as-nixos-b"; # Define your hostname.

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "16.03";

  fileSystems."/" =
    {
      encrypted =
        {
          enable = true;
          blkDev = "/dev/disk/by-uuid/c4241018-621a-46c8-bed3-d7ef1ae9d669";
          label = "nixos_root_b";
        };
      device = "/dev/mapper/nixos_root_b";
      fsType = "xfs";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/4d333dca-6017-4d5b-b772-59e4f17345e7";
      fsType = "ext4";
    };

  swapDevices = [{ device = "/dev/disk/by-uuid/d90c1243-4af3-410e-a7cc-a7e3ee16c985"; }];

  fileSystems."/home" =
    {
      encrypted =
        {
          enable = true;
          blkDev = "/dev/disk/by-uuid/ba83dd26-56f1-4876-949c-47018abf98cc";
          label = "nixos_home_a";
          keyFile = "/mnt-root/etc/home.key";
        };
      device = "/dev/mapper/nixos_home_a";
      fsType = "xfs";
    };

  fileSystems."/home/kr2/Encrypted" =
    {
      encrypted =
        {
          enable = true;
          blkDev = "/dev/disk/by-uuid/9504a8f3-e3fd-4189-8779-ad6aa095ee1f";
          label = "enc";
          keyFile = "/mnt-root/etc/enc.key";
        };
      device = "/dev/mapper/enc";
      fsType = "xfs";
      options = [ "ro" ];
    };

}
