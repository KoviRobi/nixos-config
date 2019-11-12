# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let mypkgs = import ../pkgs/all-packages.nix { nixpkgs = pkgs; };
in
{
  imports =
  [ ./base-configuration.nix
    ../modules/ssh.nix
    (import ../modules/avahi.nix { publish = true; })
  ];

  zramSwap.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.extraModulePackages = [ mypkgs.linuxPackages.yogabook-c930-eink-driver ];

  environment.systemPackages = with pkgs; [ networkmanagerapplet ];
  networking.hostName = "C930-sd";
  networking.networkmanager = { enable = true; enableStrongSwan = true; };

  time.timeZone = "Europe/London";

  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPorts = [ ];

  services.printing =
  { enable = true;
    clientConf = "ServerName cups-serv.cl.cam.ac.uk";
  };

  services.xserver.libinput.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?
}
