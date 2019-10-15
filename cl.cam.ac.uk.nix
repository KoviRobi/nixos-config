# vim: set ts=2 sts=2 sw=2 et :
{ config, lib, pkgs, ... }:

{ imports =
  [ ./base-configuration.nix
    ./hardware-configuration-orfina.nix
    ./extra-grub.nix
    ./ssh.nix
    (import ./music.nix { music-fs-uuid = "b5cb1ef0-7603-4d71-b107-c5ab11c76e17"; })
    #(import ./avahi.nix { publish = false; })
  ];

  environment.etc."nixos/configuration.nix" =
  { source = "/etc/nixos/cl.cam.ac.uk.nix"; };

  environment.systemPackages = with pkgs;
  [ networkmanagerapplet
  ] ++ (with pkgs.xorg; [ xf86videointel xf86videonouveau ]);

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "nodev"; # or "nodev" for efi only

  boot.extraModulePackages = with pkgs.linuxPackages; [ rtl8812au ];

  fileSystems."/local/scratch" =
  { device = "/dev/disk/by-uuid/88efc89a-1372-408d-9a2f-32b859fc0d06";
    fsType = "ext4";
  };

  networking =
  { hostName = "orfina.sm.cl.cam.ac.uk"; # Define your hostname.
    networkmanager = { enable = true; enableStrongSwan = true; };
  };

  services.printing =
  { enable = true;
    clientConf = "ServerName cups-serv.cl.cam.ac.uk";
  };

  services.logind.extraConfig = "HandlePowerKey=suspend";

  services.xserver.videoDrivers = [ "intel" "nouveau" "vesa" "modesetting" ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.03"; # Did you read the comment?
}
