# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./base-configuration.nix
    (import ../modules/default-user.nix { })
    ../modules/ssh.nix
    ../modules/bluetooth.nix
    ../modules/graphical.nix
    (import ../modules/avahi.nix { publish = true; })
  ];

  boot = {
    # For non-scrambled text
    initrd.availableKernelModules = [ "i915" ];
    kernelParams = [
      "video=efifb"
      "fbcon=rotate:1"
    ]; # Rotate console
    initrd.kernelModules = [
      "pinctrl_sunrisepoint" # For booting off SD card
    ];
  };

  environment.systemPackages = with pkgs; [ ntfs3g ];

  services = {
    blueman.enable = true;
    clamav.daemon.enable = lib.mkForce false;

    logind.lidSwitch = "suspend-then-hibernate";
    logind.extraConfig = "HandlePowerKey=suspend-then-hibernate";

    printing = {
      enable = true;
      drivers = with pkgs; [ hplip ];
    };

    libinput.enable = true;

    xserver = {
      dpi = 200;
      wacom.enable = true;
      videoDrivers = [ "intel" ];
      deviceSection = ''Option      "TearFree" "true"'';
      monitorSection = ''Option      "Rotate" "right"'';
      inputClassSections =
        [
          ''
            Identifier "touchpad"
            Driver "libinput"
            MatchIsTouchpad "on"
            Option "Tapping" "on"
            Option "TappingButtonMap" "lmr"
          ''
        ]
        ++ map
          (type: ''
            Identifier "touchscreen"
            Driver "wacom"
            MatchIs${type} "on"
            Option "TransformationMatrix" "0 1 0 -1 0 1 0 0 1"
          '')
          [
            "Touchscreen"
            "Tablet"
          ];
    };
  };
  home-manager.users.default-user.services.blueman-applet.enable = true;

  zramSwap.enable = true;
  environment.etc."systemd/sleep.conf".text = ''
    HibernateDelaySec=30m
  '';

  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPorts = [ ];

  hardware.sensor.iio.enable = true;
  powerManagement.powertop.enable = true;
  # services.tlp.enable = true;
}
