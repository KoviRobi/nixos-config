# vim: set ts=2 sts=2 sw=2 et :
{ config, lib, pkgs, ... }:

{ imports =
  [ ./base-configuration.nix
    ../modules/ssh.nix
    (import ../modules/avahi.nix { publish = true; })
    (import ../modules/music.nix { music-fs-uuid = "3a0b0492-af85-426c-8c1f-ee6a0df3bd48"; })
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.kr2 =
  { name = "kr2";
    group = "users";
    extraGroups =
    [ "wheel" "video" "audio" "networkmanager"
      "dialout" "docker" "wireshark" "xen"
      "docker" "games"
    ];
    uid = 1000;
    createHome = true;
    home = "/home/kr2";
    shell = pkgs.zsh;
  };

  services.xserver.dpi = 109;
  services.thermald.enable = true;

  hardware.acpilight.enable = true;

  networking.firewall.allowedTCPPorts = [ 8123 ];

  boot.initrd.availableKernelModules = [ "ehci_pci" "ata_piix" "xhci_pci" "usbhid" "usb_storage" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = with pkgs.linuxPackages; [ acpi_call rtl8812au ];
  boot.supportedFilesystems = [ "xfs" "btrfs" ];

  # services.xserver.displayManager.desktopManagerHandlesLidAndPower = false;
  services.xserver.synaptics =
  { enable = true;
    palmDetect = true;
    twoFingerScroll = true;
    additionalOptions =
    ''
      Option "CircularScrolling" "true"
    '';
  };
  services.xserver.inputClassSections = [ ''
    Identifier "touchpad catchall"
    Driver "synaptics"
    MatchIsTouchpad "on"
    MatchDevicePath "/dev/input/event*"
    Option "TapButton1" "1"
    Option "TapButton2" "2"
    Option "TapButton3" "3"
  '' ];

  nixpkgs.config.allowUnfree = true; # For nvidia_x11_legacy390, from bumblebee
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_390;
  hardware.bumblebee =
  { enable = true;
    driver = "nvidia"; #driver = "nouveau";
    connectDisplay = true; # only nvidia supports this
  };
  hardware.opengl.driSupport32Bit = true;

  services.printing.enable = true;

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

  nix.maxJobs = 8;
}
