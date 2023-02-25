# vim: set ts=2 sts=2 sw=2 et :
{ config, pkgs, ... }:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
  home-manager.users.default-user.home.stateVersion = "23.05";

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/fcd1faed-c003-4472-a4ac-02dc2b8f8d61";
      fsType = "xfs";
    };

  boot.initrd.luks.devices."hp-nixos-a".device = "/dev/disk/by-uuid/ed308956-0c94-4cd2-a8a5-9e6aa9ff22f8";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/30C3-618E";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/3fb4611d-ac00-4bfa-b6d1-d51b98a9d67f"; }
    ];

}
