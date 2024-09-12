# vim: set ts=2 sts=2 sw=2 et :
{ config, lib, pkgs, ... }@args:

{
  imports =
    [
      ./base-configuration.nix
      (import ../modules/default-user.nix { })
      ../modules/initrd-ssh.nix
      ../modules/ssh.nix
      ../modules/bluetooth.nix
      ../modules/graphical.nix
      (import ../modules/avahi.nix { publish = true; })
      (import ../modules/git-appraise-rob.nix { auth = false; })
    ];

  networking.useDHCP = false;
  initrd-ssh.interface = "enp34s0";
  initrd-ssh.udhcpcExtraArgs = [ "-b" ];
  networking.interfaces.enp34s0.wakeOnLan.enable = true;

  services.resolved.enable = true;

  virtualisation.docker.enable = true;
  users.users.default-user.extraGroups = [ "scanner" "lp" "docker" "libvirtd" ];

  virtualisation.libvirtd.enable = true;

  solarized.brightness = "light";

  nixpkgs.config.allowUnfree = true; # For google chrome (for DRM :( )
  boot.initrd.availableKernelModules =
    [ "nvme" "xhci_pci" "ahci" "usbhid" "uas" "sd_mod" "sr_mod" ]
    ++ [ "r8169" "igb" ]; # NIC for initrd SSH

  boot.kernelModules = [ "kvm-amd" "vfio" ];

  boot.kernelParams = [ "video=card0-DP-1:1366x768M@60" ];

  boot.blacklistedKernelModules = [ "iwlwifi" "btintel" ];

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  networking.firewall.allowedTCPPorts = [
    8123
    139
    445
    8200 # MiniDLNA
  ];
  networking.firewall.allowedUDPPorts = [
    137
    138
    1900 # MiniDLNA
  ];

  networking.networkmanager.appendNameservers = [ "1.1.1.1" "1.1.0.0" ];

  services.xserver =
    {
      dpi = 109;
      videoDrivers = [ "amdgpu" "cirrus" "vesa" "vmware" "modesetting" ];
      deviceSection = ''Option     "Accel" "true"'';
      serverFlagsSection = ''Option "BlankTime" "0"'';
      xrandrHeads = [
        # { output = "DisplayPort-0"; monitorConfig = ''Option "PreferredMode" "1366x768"''; }
        { output = "DisplayPort-2"; monitorConfig = ''Option "PreferredMode" "1920x1080"''; primary = true; }
        { output = "HDMI-A-0"; monitorConfig = ''Option "PreferredMode" "1366x768"''; }
      ];
    };
  hardware.graphics.enable32Bit = true;

  services.printing = { enable = true; drivers = [ pkgs.cups-zj-58 pkgs.hplipWithPlugin pkgs.cups-brother-hll2340dw ]; };
  hardware.sane = { enable = true; extraBackends = [ pkgs.sane-airscan pkgs.hplipWithPlugin ]; };

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
      # PS3 eye
      SUBSYSTEM=="video4linux", ATTRS{manufacturer}=="OmniVision Technologies, Inc.", RUN="${pkgs.v4l-utils}/bin/v4l2-ctl -d $devnode --set-ctrl=auto_exposure=1 --set-ctrl=exposure=60"

      SUBSYSTEM=="tty", ATTRS{product}=="piprinter", SYMLINK+="ttyPiPrinter"

      # Raspberry Pi Picoprobe
      ATTRS{idVendor}=="2e8a", ATTRS{idProduct}=="0004", MODE="660", GROUP="plugdev", TAG+="uaccess"

      # fx2lafw logic analyser
      ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="608c", MODE="660", GROUP="plugdev", TAG+="uaccess"

      KERNEL=="nvme0n1p6", SUBSYSTEM=="block", group="${config.users.users.default-user.group}"

      # ICELINK
      ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="602b", MODE="660", TAG+="uaccess"

      # iCESugar compatible adapters
      ATTRS{product}=="*iCESugar*", MODE="660", TAG+="uaccess"

      # iCELink compatible adapters
      ATTRS{product}=="*iCELink*", MODE="660", TAG+="uaccess"

      # iCELink compatible adapters (NXP ARM mbed)
      ATTRS{product}=="*DAPLink*", MODE="660", TAG+="uaccess"
      ATTRS{product}=="*FPGALink*", MODE="660", TAG+="uaccess"
      ATTRS{product}=="*NXP ARM mbed*", MODE="660", TAG+="uaccess"
    '';

  services.logind.extraConfig = "HandlePowerKey=suspend";

  home-manager.users.default-user = {
    xsession.initExtra = ''
      ${pkgs.antimicroX}/bin/antimicrox --profile ~/SpacePilot.joystick.amgp --tray --hidden &
    '';
  };

  nix.settings.max-jobs = 24;
  nix.sshServe.enable = true;
  nix.sshServe.write = true;
  nix.sshServe.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILaXof9mjOhih0JV+nlD8FThOFQqsnloT+nTv4ayEjlH root@cc-vm-nixos-a"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICD3Cj4mJJJX98KxJkGjlPk8PkYu3dWosnWqOcQ9Qwlo root@C930-flash"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF+PcJ5ujl3/I+DjPW+WxRBJ4GLStWb30RPj8HyM1Ey8 root@hp-nixos-a"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF8kc9byAsBL3Jt1zynOKBrDjp/Uwm774ymj3DoPNVSi root@cc-wsl"
  ];
  # Set modules/ssh.nix to not require authenticator key for nix-ssh
  users.users.nix-ssh.extraGroups = [ "no-google-authenticator" ];
  nix.settings.trusted-users = [ "nix-ssh" ];

  security.sudo.extraRules = [{
    groups = [ "wheel" ];
    commands = [{
      command = "/run/current-system/sw/bin/bootctl set-oneshot *";
      options = [ "NOPASSWD" ];
    }];
  }];
  environment.systemPackages = [
    pkgs.nvtopPackages.amd
    pkgs.docker-credential-helpers
    pkgs.virt-manager
    (pkgs.writeShellScriptBin "rewin" ''sudo bootctl set-oneshot auto-windows; reboot'')
  ]
  ++ (import ../packages/pc.nix args)
  ++ (import ../packages/pc-unfree.nix args);


  users.extraUsers.alex =
    {
      isNormalUser = true;
      name = "alex";
      group = "users";
      createHome = true;
      shell = pkgs.zsh;
    };


  services.minidlna = {
    enable = true;
    settings.media_dir = [ "/video/" "/music/" ];
  };

  nix.settings.secret-key-files = "/etc/secrets/nix/secret-key";
}
