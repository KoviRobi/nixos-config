# nix build -f <nixpkgs/nixos> config.system.build.isoImage -I nixos-config=iso.nix
{ config, pkgs, ... }:

let mypkgs = import ./pkgs/all-packages.nix { nixpkgs = pkgs; };
in
{
  imports =
  [ ./base-configuration.nix
    <nixpkgs/nixos/modules/installer/cd-dvd/iso-image.nix>
    ./ssh.nix
    (import ./avahi.nix { publish = true; })
  ];

  zramSwap.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.extraModulePackages = [ mypkgs.linuxPackages.yogabook-c930-eink-driver ];

  environment.etc."nixos/configuration.nix" =
  { source = "/etc/nixos/sd-configuration.nix"; };

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
