{
  imports = [
    (import ../modules/music.nix { music-fs-uuid = "7ccc6d89-f028-4ca5-85c8-1e4b3cf69517"; })
  ];

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    initrd.luks.devices."pc-nixos-b".device = "/dev/disk/by-uuid/928d2553-cc61-4764-b2d6-263e127a3018";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
  home-manager.users.default-user.home.stateVersion = "25.05";
  home-manager.users.root.home.stateVersion = "25.05";

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/e02bf1bb-8c67-4ce7-b1c9-98b6236bc125";
      fsType = "btrfs";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/5937-E30E";
      fsType = "vfat";
      options = [ "umask=0077" ];
    };
  };

  swapDevices = [ ];
}
