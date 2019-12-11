# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
  [ ./base-configuration.nix
    ../modules/ssh.nix
    (import ../modules/avahi.nix { publish = true; })
  ];

  # For non-scrambled text
  boot.initrd.availableKernelModules = [ "i915" ];
  boot.initrd.kernelModules = [ "eink" "pinctrl_sunrisepoint" ];
  boot.kernelParams = [ "video=efifb" "fbcon=rotate:1" ];

  zramSwap.enable = true;

  boot.extraModulePackages = [ pkgs.linuxPackages.yogabook-c930-eink-driver ];

  services.acpid =
  let restart-eink-kbd = ''
      PATH=${pkgs.kmod}/bin:$PATH
      modprobe -r eink
      modprobe eink
    '';
  in { enable = true;
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

  services.logind.extraConfig = "HandlePowerKey=suspend";

  hardware.sensor.iio.enable = true;
  services.xserver.libinput.enable = true;
  services.xserver.dpi = 281;
  services.xserver.wacom.enable = true;
  services.xserver.videoDrivers = [ "intel" ];
  services.xserver.deviceSection = ''Option      "TearFree" "true"'';

  security.pam.services.login.fprintAuth = true;
  services.fprintd.enable = true;
  services.fprintd.package = pkgs.fprintd-thinkpad;
}
