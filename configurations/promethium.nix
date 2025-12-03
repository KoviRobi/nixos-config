# vim: set ts=2 sts=2 sw=2 et :
{
  lib,
  pkgs,
  config,
  ...
}:

{
  imports = [
    ./base-configuration.nix
    ./carallon.nix
    ../modules/graphical.nix
    (import ../modules/default-user.nix { })
    ../modules/ssh.nix
    ../modules/graphical.nix
    ../modules/bluetooth.nix
    ../modules/initrd-ssh.nix
  ];

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "saleae-logic-2"
      "saleae-logic"
    ];

  boot = {
    initrd = {
      kernelModules = [ "8021q" ];
      postMountCommands = ''
      ip link set dev enp0s31f6.2 down
      ip link delete enp0s31f6.2
      '';
      preLVMCommands = lib.mkAfter ''
        # Prime the network
        ( while true; do ping 172.20.16.250; sleep 1; done ) &
      '';
    };
    # For PCIe passhtrough
    kernelParams = [ "intel_iommu=on" ];
  };

  initrd-ssh = {
    interface = "enp0s31f6.2";
    extraInterfaceCommands = [
      "ip link set dev enp0s31f6 up"
      "ip link add link enp0s31f6 name enp0s31f6.2 type vlan id 2"
      "ip link set dev enp0s31f6.2 up"
    ];
    udhcpcExtraArgs = [
      "-t 10"
      "-b"
      "-x"
      "61:0130d042ec62ef"
    ];
  };
  systemd.targets.emergency.wants = [ "sshd.service" ];

  services = {
    lldpd.enable = true;
    xserver.dpi = 93;
    udev.packages = with pkgs; [ saleae-logic-2 ];

    printing = {
      enable = true;
      drivers = [
        pkgs.hplip
        pkgs.go-catprinter
      ];
      bindirCmds = ''
        mkdir -p $out/lib/cups/backend
        ln -sf ${pkgs.writeShellScript "smb-krb5" ''
          export DEVICE_URI=smb://''${DEVICE_URI#smb_krb5://}
          ${config.services.samba.package}/libexec/samba/smbspool_krb5_wrapper "$@"
        ''} $out/lib/cups/backend/smb_krb5
      '';
    };

    samba = {
      settings = {
        public = {
          browseable = "yes";
          comment = "Public samba share.";
          "guest ok" = "yes";
          path = "/srv/share";
          "read only" = "yes";
          "hosts allow" = "10.0.0.1/24 localhost";
        };
      };
    };
  };

  virtualisation = {
    lxc.enable = true;
    docker = {
      enable = true;
    };
    podman = {
      enable = true;
    };
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
    "lxd"
    "_lldpd"
  ];

  environment.unixODBCDrivers = [
    pkgs.unixODBCDrivers.sqlite
    pkgs.unixODBCDrivers.psql
  ];

  environment.systemPackages = with pkgs; [
    obs-studio
    virt-manager
    virtiofsd
    spice-gtk # For USB redirection
    swtpm
    sigrok-cli
    pulseview
    saleae-logic-2
    google-chrome
    mcuxpresso
    (pkgs.writeShellScriptBin "resus" ''systemctl reboot --boot-loader-entry=opensuse.conf'')
  ];

  services.jenkins = {
    enable = true;
    port = 8132;
    extraGroups = [
      "docker"
    ];
    packages = [
      pkgs.stdenv
      pkgs.docker
      pkgs.git
      pkgs.jdk
      config.programs.ssh.package
      pkgs.nix
      pkgs.busybox
      pkgs.cmake
    ];
    extraJavaOptions = [
      "-Dorg.jenkinsci.plugins.durabletask.BourneShellScript.LAUNCH_DIAGNOSTICS=true"
    ];
  };

  networking.firewall.interfaces = {
    private-bridge.allowedUDPPorts = [
      67 # bootps
    ];
    pi-bridge.allowedUDPPorts = [
      67 # bootps
    ];
    rnd-bridge.allowedUDPPorts = [
      67 # bootps
    ];
    manatee-bridge.allowedUDPPorts = [
      67 # bootps
      69 # tftp
    ];
    rnd-bridge.allowedTCPPorts = [
      139 # netbios-ssn
      445 # microsoft-ds
    ];
  };
}
