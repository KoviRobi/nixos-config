# vim: set ts=2 sts=2 sw=2 et :
{ config, lib, pkgs, ... }:

{ imports =
  [ ./base-configuration.nix
    (import ../modules/default-user.nix { })
    ../modules/ssh.nix
    ../modules/bluetooth.nix
    ../modules/graphical.nix
    (import ../modules/avahi.nix { publish = true; })
  ];

  # nixpkgs.config.allowUnfree = true; # For amdgpu-pro, for OpenCL
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.extraModulePackages = with config.boot.kernelPackages; [ amdgpu-pro ]; # for OpenCL
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "uas" "sd_mod" "sr_mod" ];
  boot.kernelModules = [ "kvm-amd" "vfio" ];

  boot.kernelParams = [ "video=card0-DP-1:1366x768M@60" ];

  virtualisation.libvirtd = { enable = true; qemuRunAsRoot = false; };

  environment.systemPackages = with pkgs; [ virt-manager ];

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  networking.firewall.allowedTCPPorts = [ 8123 ];

  services.xserver =
    { dpi = 109;
      videoDrivers = [ "amdgpu" "cirrus" "vesa" "vmware" "modesetting" ];
      deviceSection = ''Option     "Accel" "true"'';
      xrandrHeads = [
        { output = "HDMI-A-0"; monitorConfig = ''Option "PreferredMode" "1366x768"''; }
        { output = "DisplayPort-2"; monitorConfig = ''Option "PreferredMode" "1920x1080"''; }
      ];
    };
  hardware.opengl.driSupport32Bit = true;

  services.printing = { enable = true; drivers = [ pkgs.hplip ]; };

  services.udev.extraRules =
  ''
    # IceStick
    ACTION=="add", ATTR{idVendor}=="0403", ATTR{idProduct}=="6010", MODE:="666", SYMLINK="latticeFTDI"
    # Next 4 are Teensy
    ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789A]?", ENV{MTP_NO_PROBE}="1"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789ABCD]?", MODE:="0666"
    KERNEL=="ttyACM*", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", MODE:="0666"
    # Redmi 4A
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="2717", ATTRS{idProduct}=="ff40", MODE="0666", OWNER="kr2"
  '';
  services.udev.packages = [ pkgs.stlink ];

  services.logind.extraConfig = "HandlePowerKey=suspend";

  nix.maxJobs = 24;
}