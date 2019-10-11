# vim: set ts=2 sts=2 sw=2 et :
{ config, lib, pkgs, ... }:

{ imports =
  [ ./base-configuration.nix
    ./hardware-configuration-orfina.nix
    ./music.nix
    ./extra-grub.nix
    ./ssh.nix
    (import ./avahi.nix { publish = false; })
  ];

  environment.etc."nixos/configuration.nix" =
  { source = "/etc/nixos/cl.cam.ac.uk.nix"; };

  environment.systemPackages = with pkgs;
  [ nfs-utils
    networkmanagerapplet
  ] ++ (with pkgs.xorg; [ xf86videointel xf86videonouveau ]);

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  #boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only
  boot.loader.grub.device = "nodev"; # or "nodev" for efi only

  boot.extraModulePackages = with pkgs.linuxPackages; [ rtl8812au ];

  services.nfs.extraConfig = "NEED_GSSD=yes";
  #fileSystems."/mnt" =
  #{ device = "elmer.cl.cam.ac.uk:/";
  #  fsType = "nfs4";
  #  options = [ "sec=krb5" ];
  #};
  #systemd.services.auth-rpcgss-module.unitConfig.ConditionPathExists = lib.mkOverride 10 [""];
  #systemd.services.rpc-gssd.unitConfig.ConditionPathExists = lib.mkOverride 10 [""];

  fileSystems."/local/scratch" =
  { device = "/dev/disk/by-uuid/88efc89a-1372-408d-9a2f-32b859fc0d06";
    fsType = "ext4";
  };

  networking =
  { hostName = "orfina.sm.cl.cam.ac.uk"; # Define your hostname.
    networkmanager = { enable = true; enableStrongSwan = true; };
    #domain = "cl.cam.ac.uk";
    # interfaces."eno1" =
    # { ipv4.addresses =
    #   [ { addresses = "128.232.60.36"; prefixLength = 22 } ];
    #   useDHCP = false;
    # };
    # defaultGateway = { address = "128.232.60.1"; interface = "eno1"; }
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
