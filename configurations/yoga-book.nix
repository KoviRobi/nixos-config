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
    "eink"
  ];
  boot.kernelPackages = pkgs.linuxPackages.extend (self: super: {
    yogabook-c930-eink-driver = self.callPackage
      (pkgs.fetchgit {
        url = "https://github.com/KoviRobi/yogabook-c930-linux-eink-driver";
        rev = "d990b6295034436c3ac8aa451526eb2864553d9b";
        sha256 = "0ysz0y0bxr17fpzys2k8a0frzb681g4qvdnm4i9arcqc38b61xha";
        fetchSubmodules = false;
      })
      { };
  });
  boot.extraModulePackages = [ pkgs.linuxPackages.yogabook-c930-eink-driver ];

  environment.systemPackages = with pkgs; [ ntfs3g ]
    ++ (import ../packages/desktop-environment.nix args);

  services.blueman.enable = true;
  services.clamav.daemon.enable = lib.mkForce false;
  home-manager.users.default-user.services.blueman-applet.enable = true;
  hardware.pulseaudio.extraModules = with pkgs; [ pulseaudio-modules-bt ];
  hardware.pulseaudio.extraConfig = "load-module module-bluetooth-discover";

  # To restart e-ink keyboard
  services.acpid =
    let restart-eink-kbd = ''
      PATH=${pkgs.kmod}/bin:$PATH
      modprobe -r eink
      modprobe eink
    '';
    in
    {
      enable = true;
      handlers = {
        vol-keyboard = { event = "button/volumeup"; action = restart-eink-kbd; };
      };
    };

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
