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

  boot.extraModulePackages = [ mypkgs.linuxPackages.yogabook-c930-eink-driver ];

  services.logind.extraConfig = ''
    HandleLidSwitch=ignore
    HandlePowerKey=ignore
  '';
  services.acpid =
  let restart-eink-kbd = ''
      PATH=${pkgs.kmod}/bin:$PATH
      modprobe -r eink wacom
      modprobe eink
      modprobe wacom
    '';
  in { enable = true;
       lidEventCommands = restart-eink-kbd;
       powerEventCommands = restart-eink-kbd;
       handlers = {
         vol-keyboard = { event = "button/volumeup"; action = restart-eink-kbd; };
       };
  };

  time.timeZone = "Europe/London";

  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPorts = [ ];

  # services.printing =
  # { enable = true;
  #   clientConf = "ServerName cups-serv.cl.cam.ac.uk";
  # };

  services.xserver.libinput.enable = true;
  services.xserver.dpi = 200;

  security.pam.services.login.fprintAuth = true;
  services.fprintd.enable = true;
}
