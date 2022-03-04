# vim: set ts=2 sts=2 sw=2 et :
{ config, lib, pkgs, ... }:

{
  imports = [ ./cc.nix ];

  services.xserver.dpi = 120;

  boot.initrd.availableKernelModules = [ "ata_piix" "mptspi" "uhci_hcd" "ehci_pci" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];


  home-manager.users.default-user = {
    services.screen-locker.enable = lib.mkForce false;
    xsession.windowManager.i3.config.bars = lib.mkForce [{
      fonts = { names = [ "Latin Modern Roman" ]; style = "Regular"; size = 9.0; };
    }];
  };

  networking.hostName = "cc-nixos-a"; # Define your hostname.

  virtualisation.vmware.guest = { enable = true; };

  services.xserver = {
    inputClassSections = [
      ''
        Identifier "VMMouse"
        MatchDevicePath "/dev/input/event*"
        MatchProduct "ImPS/2 Generic Wheel Mouse"
        Option "EmulateWheel" "1"
        Option "EmulateWheelButton" "2"
        Option "XAxisMapping" "6 7
        Option "YAxisMapping" "4 5"
      ''
    ];
    xkbOptions = "caps:escape";

    displayManager.sessionCommands = ''
      ${pkgs.i3}/bin/i3-msg workspace 1
      ${pkgs.open-vm-tools}/bin/vmware-user-suid-wrapper
      sleep 5s && ~/.fehbg
    '';
  };

  fileSystems."/shared" =
    {
      device = ".host:/";
      fsType = "fuse./run/current-system/sw/bin/vmhgfs-fuse";
      options = [
        "uid=${toString config.users.users.default-user.uid}"
        "gid=${toString config.users.groups.default-user.gid}"
        "allow_other"
      ];
    };

  nix.settings.max-jobs = 4;
  nix.buildMachines = [
    {
      hostName = "192.168.0.29";
      maxJobs = 24;
      speedFactor = 5;
      sshKey = "/root/.ssh/pc-build";
      sshUser = "nix-ssh";
      system = "x86_64-linux";
    }
  ];
  nix.distributedBuilds = true;
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';
}
