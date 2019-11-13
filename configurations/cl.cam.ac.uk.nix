# vim: set ts=2 sts=2 sw=2 et :
{ config, lib, pkgs, ... }:

{ imports =
  [ ./base-configuration.nix
    ../modules/ssh.nix
    #(import ../modules/avahi.nix { publish = false; })
  ];

  environment.systemPackages = with pkgs;
  [ networkmanagerapplet
  ] ++ (with pkgs.xorg; [ xf86videointel xf86videonouveau ]);

  networking.networkmanager = { enable = true; enableStrongSwan = true; };

  services.printing =
  { enable = true;
    clientConf = "ServerName cups-serv.cl.cam.ac.uk";
  };

  services.logind.extraConfig = "HandlePowerKey=suspend";

  # nix.binaryCaches = [ "http://caelum-vm-127.cl.cam.ac.uk:5000/" ];
  # nix.binaryCachePublicKeys =
  #   [ "caelum-vm-127.cl.cam.ac.uk:g8nVJlP6fBid6ukx0ciaBUes2ruN9c849laqj2xNoe8=" ];

  #services.hydra = { enable = true; hydraURL = "caelum-vm-127.cl.cam.ac.uk";
  #  notificationSender = "hydra@caelum-vm-127.cl.cam.ac.uk";
  #  useSubstitutes = true; };
  #services.nix-serve = { enable = true; };
}