# vim: set ts=2 sts=2 sw=2 et :
{
  config,
  pkgs,
  ...
}@args:

{
  imports = [
    ./base-configuration.nix
    (import ../modules/default-user.nix { })
    ../modules/initrd-ssh.nix
    ../modules/ssh.nix
    ../modules/bluetooth.nix
    ../modules/graphical.nix
    (import ../modules/avahi.nix { publish = true; })
  ];

  networking = {
    useDHCP = false;
    interfaces.enp34s0.wakeOnLan.enable = true;

    firewall = {
      interfaces.enp38s0f1.allowedUDPPorts = [
        67 # bootps
        69 # tftp
        111 # sunrpc (for NFS)
        2049 # NFS
        4000 # statd (for NFS, see below)
        4001 # lockd (for NFS, see below)
        4002 # mountd (for NFS, see below)
      ];
      interfaces.enp38s0f1.allowedTCPPorts = [
        69 # tftp
        111 # sunrpc (for NFS)
        2049 # NFS
        4000 # statd (for NFS, see below)
        4001 # lockd (for NFS, see below)
        4002 # mountd (for NFS, see below)
      ];

      allowedTCPPorts = [
        8123
        139
        445
        8200 # MiniDLNA
      ];
      allowedUDPPorts = [
        137
        138
        1900 # MiniDLNA
      ];
    };

    networkmanager.appendNameservers = [
      "1.1.1.1"
      "1.1.0.0"
    ];
  };

  initrd-ssh.interface = "enp34s0";
  initrd-ssh.udhcpcExtraArgs = [ "-b" ];

  services = {
    nfs.server = {
      enable = true;
      statdPort = 4000;
      lockdPort = 4001;
      mountdPort = 4002;
      exports = ''
        /nfs *(rw,sync,no_subtree_check,no_root_squash)
        /tftpboot *(rw,sync,no_subtree_check,no_root_squash)
      '';
    };

    xserver = {
      dpi = 109;
      videoDrivers = [
        "amdgpu"
        "cirrus"
        "vesa"
        "vmware"
        "modesetting"
      ];
      deviceSection = ''Option     "Accel" "true"'';
      serverFlagsSection = ''Option "BlankTime" "0"'';
      xrandrHeads = [
        # { output = "DisplayPort-0"; monitorConfig = ''Option "PreferredMode" "1366x768"''; }
        {
          output = "DisplayPort-2";
          monitorConfig = ''Option "PreferredMode" "1920x1080"'';
          primary = true;
        }
        {
          output = "HDMI-A-0";
          monitorConfig = ''Option "PreferredMode" "1366x768"'';
        }
      ];
    };

    printing = {
      enable = true;
      drivers = [
        pkgs.cups-brother-hll2340dw
        pkgs.go-catprinter
      ];
    };

    udev.extraRules = ''
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

      KERNEL=="nvme0n1p6", SUBSYSTEM=="block", GROUP="${config.users.users.default-user.group}"

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

    logind.powerKey = "suspend";

    minidlna = {
      enable = true;
      settings.media_dir = [
        "/video/"
        "/music/"
      ];
    };
  };

  virtualisation = {
    docker.enable = true;
    podman.enable = true;

    libvirtd = {
      enable = true;
      nss.enableGuest = true;
      qemu = {
        vhostUserPackages = [ pkgs.virtiofsd ];
        swtpm = {
          enable = true;
        };
      };
    };
  };

  users.users.default-user.extraGroups = [
    "scanner"
    "lp"
    "docker"
    "libvirtd"
  ];

  # For google chrome (for DRM :( )
  nixpkgs.config.allowUnfree = true;

  boot = {
    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "ahci"
      "usbhid"
      "uas"
      "sd_mod"
      "sr_mod"
    ]
    ++ [
      "r8169"
      "igb"
    ]; # NIC for initrd SSH

    kernelModules = [
      "kvm-amd"
      "vfio"
    ];

    kernelParams = [ "video=card0-DP-1:1366x768M@60" ];

    blacklistedKernelModules = [
      "iwlwifi"
      "btintel"
    ];
  };

  hardware = {
    cpu.amd.updateMicrocode = true;
    enableRedistributableFirmware = true;
    graphics.enable32Bit = true;
    sane = {
      enable = true;
      extraBackends = [
        pkgs.sane-airscan
      ];
    };
  };

  nix = {
    settings = {
      max-jobs = 24;
      trusted-users = [ "nix-ssh" ];

      secret-key-files = "/etc/secrets/nix/secret-key";
    };

    sshServe = {
      enable = true;
      write = true;
      keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILaXof9mjOhih0JV+nlD8FThOFQqsnloT+nTv4ayEjlH root@cc-vm-nixos-a"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICD3Cj4mJJJX98KxJkGjlPk8PkYu3dWosnWqOcQ9Qwlo root@C930-flash"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF+PcJ5ujl3/I+DjPW+WxRBJ4GLStWb30RPj8HyM1Ey8 root@hp-nixos-a"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF8kc9byAsBL3Jt1zynOKBrDjp/Uwm774ymj3DoPNVSi root@cc-wsl"
      ];
    };
  };

  # Set modules/ssh.nix to not require authenticator key for nix-ssh
  users.users.nix-ssh.extraGroups = [ "no-google-authenticator" ];

  security.sudo.extraRules = [
    {
      groups = [ "wheel" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/bootctl set-oneshot *";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
  environment.systemPackages = [
    pkgs.nvtopPackages.amd
    pkgs.docker-credential-helpers
    pkgs.virt-manager
    (pkgs.writeShellScriptBin "rewin" ''sudo bootctl set-oneshot auto-windows; reboot'')
    pkgs.wineWowPackages.full
    pkgs.winetricks
  ]
  ++ (import ../packages/pc.nix args)
  ++ (import ../packages/pc-unfree.nix args);
}
