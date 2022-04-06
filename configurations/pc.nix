# vim: set ts=2 sts=2 sw=2 et :
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

  virtualisation.docker.enable = true;
  users.users.default-user.extraGroups = [ "docker" ];

  solarized.brightness = "light";

  nixpkgs.config.allowUnfree = true; # For google chrome (for DRM :( )
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.extraModulePackages = with config.boot.kernelPackages; [ amdgpu-pro ]; # for OpenCL
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "uas" "sd_mod" "sr_mod" ];
  boot.kernelModules = [ "kvm-amd" "vfio" ];

  boot.kernelParams = [ "video=card0-DP-1:1366x768M@60" ];

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  networking.firewall.allowedTCPPorts = [ 8123 139 445 ];
  networking.firewall.allowedUDPPorts = [
    137
    138
  ];

  # WireGuard
  networking.firewall = {
    # if packets are still dropped, they will show up in dmesg
    logReversePathDrops = true;
    # wireguard trips rpfilter up
    extraCommands = ''
      ip46tables -t raw -I nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN
      ip46tables -t raw -I nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN
    '';
    extraStopCommands = ''
      ip46tables -t raw -D nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN || true
      ip46tables -t raw -D nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN || true
    '';
  };

  networking.networkmanager.insertNameservers = [ "1.1.1.1" "1.1.0.0" ];

  services.xserver =
    {
      dpi = 109;
      videoDrivers = [ "amdgpu" "cirrus" "vesa" "vmware" "modesetting" ];
      deviceSection = ''Option     "Accel" "true"'';
      serverFlagsSection = ''Option "BlankTime" "0"'';
      xrandrHeads = [
        { output = "HDMI-A-0"; monitorConfig = ''Option "PreferredMode" "1366x768"''; }
        { output = "DisplayPort-2"; monitorConfig = ''Option "PreferredMode" "1920x1080"''; }
        { output = "DisplayPort-0"; monitorConfig = ''Option "PreferredMode" "1366x768"''; }
      ];
    };
  hardware.opengl.driSupport32Bit = true;

  services.printing = { enable = true; drivers = [ pkgs.cups-zj-58 pkgs.hplip ]; };

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
    '';

  services.udev.packages = [ pkgs.stlink ];

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
    pkgs.docker-credential-helpers
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


  services.samba = {
    enable = true;
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
      server string = smbnix
      netbios name = smbnix
      security = user
      #use sendfile = yes
      #max protocol = smb2
      hosts allow = 192.168.0.  localhost
      hosts deny = 0.0.0.0/0
      guest account = nobody
      map to guest = bad user
    '';
    shares = {
      music = {
        path = "/music";
        browseable = "yes";
        "read only" = "yes";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "nobody";
        "force group" = "nogroup";
      };
    };
  };
}
