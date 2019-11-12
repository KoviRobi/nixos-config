{ config, lib, pkgs, ... }:

{
  boot.initrd.availableKernelModules = [ "ata_piix" "ohci_pci" "ehci_pci" "ahci" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/b50309e4-2660-4306-8c2f-73d50af1bbf8";
      fsType = "xfs";
    };

  boot.initrd.luks.devices."new".device = "/dev/disk/by-uuid/f3f5109d-6da5-441b-b959-f94d8c066ce8";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/49DD-94F6";
      fsType = "vfat";
    };

  nix.maxJobs = lib.mkDefault 2;
}
