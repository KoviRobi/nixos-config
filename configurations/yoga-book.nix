# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }@args:

{
  imports =
    [
      ./base-configuration.nix
      (import ../modules/default-user.nix { })
      ../modules/ssh.nix
      ../modules/bluetooth.nix
      ../modules/graphical.nix
      (import ../modules/avahi.nix { publish = true; })
    ];

  # For non-scrambled text
  boot.initrd.availableKernelModules = [ "i915" ];
  boot.kernelParams = [ "video=efifb" "fbcon=rotate:1" ]; # Rotate console
  boot.initrd.kernelModules = [
    "pinctrl_sunrisepoint" # For booting off SD card
  ];

  environment.systemPackages = with pkgs; [ ntfs3g ];

  services.blueman.enable = true;
  services.clamav.daemon.enable = lib.mkForce false;
  home-manager.users.default-user.services.blueman-applet.enable = true;

  zramSwap.enable = true;

  services.logind.lidSwitch = "suspend-then-hibernate";
  services.logind.extraConfig = "HandlePowerKey=suspend-then-hibernate";
  environment.etc."systemd/sleep.conf".text = ''
    HibernateDelaySec=30m
  '';

  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPorts = [ ];

  services.printing = { enable = true; drivers = with pkgs; [ hplip ]; };

  hardware.sensor.iio.enable = true;
  services.xserver.libinput.enable = true;
  services.xserver.dpi = 200;
  services.xserver.wacom.enable = true;
  services.xserver.videoDrivers = [ "intel" ];
  services.xserver.deviceSection = ''Option      "TearFree" "true"'';
  services.xserver.monitorSection = ''Option      "Rotate" "right"'';
  services.xserver.inputClassSections = [
    ''
      Identifier "touchpad"
      Driver "libinput"
      MatchIsTouchpad "on"
      Option "Tapping" "on"
      Option "TappingButtonMap" "lmr"
    ''
  ] ++
  map
    (type: ''
      Identifier "touchscreen"
      Driver "wacom"
      MatchIs${type} "on"
      Option "TransformationMatrix" "0 1 0 -1 0 1 0 0 1"
    '')
    [ "Touchscreen" "Tablet" ];
  powerManagement.powertop.enable = true;
  # services.tlp.enable = true;
}
