# vim: set ts=2 sts=2 sw=2 et :
{ config, lib, pkgs, ... }:

{ imports =
  [ (import ../modules/music.nix { music-fs-uuid = "b5cb1ef0-7603-4d71-b107-c5ab11c76e17"; })
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "nodev"; # or "nodev" for efi only
  boot.loader.grub.extraEntries = ''
    menuentry "Guix" {
      search --set=drive1 --fs-uuid 8CF4-33C5
      configfile ($drive1)/grub/guix.cfg
    }
  '';

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "nvme" "usb_storage" "usbhid" "uas" "sd_mod" "sr_mod" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = with pkgs.linuxPackages; [ rtl8812au ];

  fileSystems."/" =
  { device = "/dev/disk/by-uuid/d5551e12-5224-4913-a2d5-72d5e4f1337e";
    fsType = "xfs";
  };

  boot.initrd.luks.devices."nixos".device = "/dev/disk/by-uuid/fb8206b0-f5cc-4016-9f74-0d2b05fa2ece";

  fileSystems."/boot" =
  { device = "/dev/disk/by-uuid/8CF4-33C5";
    fsType = "vfat";
  };

  swapDevices = [ ];

  nix.maxJobs = lib.mkDefault 8;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.03"; # Did you read the comment?
}
