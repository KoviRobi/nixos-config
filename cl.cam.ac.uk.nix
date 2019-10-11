# vim: set ts=2 sts=2 sw=2 et :
{ config, lib, pkgs, ... }:

{ imports =
  [ ./base-configuration.nix
    ./hardware-configuration-orfina.nix
    ./music.nix
    ./extra-grub.nix
    ./ssh.nix
  ];

  environment.etc."nixos/configuration.nix" =
  { source = "/etc/nixos/cl.cam.ac.uk.nix"; };

  environment.systemPackages = with pkgs;
  [ nfs-utils
    networkmanagerapplet
  ] ++ (with pkgs.xorg; [ xf86videointel xf86videonouveau ]);


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
}
