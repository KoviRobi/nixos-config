{ config, pkgs, ... }:
{
  imports =
    [
      (import ../modules/music.nix { music-fs-uuid = "b5cb1ef0-7603-4d71-b107-c5ab11c76e17"; })
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "pc-nixos-a"; # Define your hostname.

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/db69523e-9985-4ea6-a7b0-c0b79ee40cf1";
      fsType = "f2fs";
    };

  boot.initrd.luks.devices."pc-nixos-a".device = "/dev/disk/by-uuid/928d2553-cc61-4764-b2d6-263e127a3018";

  fileSystems."/home" =
    {
      encrypted =
        {
          enable = true;
          blkDev = "/dev/disk/by-uuid/2641b207-b2a2-4e28-934d-c2d48fc9f92d";
          label = "nixos-home-a";
          keyFile = "/mnt-root/etc/home.key";
        };
      device = "/dev/mapper/nixos-home-a";
      fsType = "f2fs";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/5937-E30E";
      fsType = "vfat";
    };

  swapDevices = [ ];
}
