# vim: set ts=2 sts=2 sw=2 et :
{ config, lib, pkgs, ... }:

{ imports =
  [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ./seagate-hdd.nix
  ];

  hardware.cpu.intel.updateMicrocode = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "nodev"; # or "nodev" for efi only

  # boot.extraModulePackages = with pkgs.linuxPackages; [ nvidia_x11_legacy304 ];

  boot.initrd.luks.devices."nixos".device = "/dev/disk/by-uuid/fb8206b0-f5cc-4016-9f74-0d2b05fa2ece";

  fileSystems."/local/scratch" =
  { device = "/dev/disk/by-uuid/88efc89a-1372-408d-9a2f-32b859fc0d06";
    fsType = "ext4";
  };

  nix.maxJobs = 8;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  networking.hostName = "orfina.sm.cl.cam.ac.uk";

  services.logind.extraConfig = "HandlePowerKey=suspend";

  services.xserver.videoDrivers = [ "intel" "nouveau" "vesa" "modesetting" ];
  #services.xserver.videoDrivers = [ "nvidiaLegacy304" ];
  #services.xserver.extraConfig = ''
  #  Section "ServerFlags"
  #    Option "IgnoreABI" "1"
  #  EndSection
  #'';
  #hardware.opengl.driSupport32Bit = true;
  #nixpkgs.config.allowUnfree = true;
}
