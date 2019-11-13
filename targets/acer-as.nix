{ config, pkgs, ... }:
{ boot.initrd.availableKernelModules = [ "ehci_pci" "ata_piix" "xhci_pci" "usbhid" "usb_storage" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = with pkgs.linuxPackages; [ rtl8812au bbswitch ];
  boot.supportedFilesystems = [ "xfs" "btrfs" ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "nodev"; # or "nodev" for efi only

  networking.hostName = "as-nixos-b"; # Define your hostname.

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "16.03";

  fileSystems."/" =
  { encrypted =
    { enable = true;
      blkDev = "/dev/disk/by-uuid/c4241018-621a-46c8-bed3-d7ef1ae9d669";
      label = "nixos_root_b";
    };
    device = "/dev/mapper/nixos_root_b";
    fsType = "xfs";
  };

  fileSystems."/boot" =
  { device = "/dev/disk/by-uuid/4d333dca-6017-4d5b-b772-59e4f17345e7";
    fsType = "ext4";
  };

  swapDevices = [ { device = "/dev/disk/by-uuid/e1db8b2f-97f8-45a6-83c4-8e45c9d474d0"; } ];

  fileSystems."/home" =
  { encrypted =
    { enable = true;
      blkDev = "/dev/disk/by-uuid/ba83dd26-56f1-4876-949c-47018abf98cc";
      label = "nixos_home_a";
      keyFile = "/mnt-root/etc/home.key";
    };
    device = "/dev/mapper/nixos_home_a";
    fsType = "xfs";
  };

  fileSystems."/home/kr2/Encrypted" =
  { encrypted =
    { enable = true;
      blkDev = "/dev/disk/by-uuid/9504a8f3-e3fd-4189-8779-ad6aa095ee1f";
      label = "enc";
      keyFile = "/mnt-root/etc/enc.key";
    };
    device = "/dev/mapper/enc";
    fsType = "xfs";
    options = [ "ro" ];
  };

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
  services.logind.extraConfig = "KillUserProcesses=yes";

  environment.systemPackages = with pkgs; [ bluez5 usb-modeswitch usb-modeswitch-data ];
  hardware.bluetooth.enable = true;
  hardware.pulseaudio.extraModules = with pkgs; [ pulseaudio-modules-bt ];
  nixpkgs.config =
  { packageOverrides = packages: { bluez = packages.bluez; };
  };

  hardware.bumblebee =
  { enable = true;
    driver = "nouveau";
    connectDisplay = true;
  };
  hardware.opengl.driSupport32Bit = true;

  services.printing =
  { enable = true;
  };

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
}
