{ lib, pkgs, ... }@args:
{
  imports = [
    ./base-configuration.nix
    (import ../modules/default-user.nix { })
    ../modules/ssh.nix
    ../modules/graphical.nix
    ../modules/bluetooth.nix
    (import ../modules/avahi.nix { publish = false; })
  ];

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

  boot.binfmt = {
    emulatedSystems = [ "x86_64-linux" ];
    registrations.x86_64-linux = {
      interpreter = lib.getExe pkgs.box64;
    };
  };

  users.users.default-user.extraGroups = [
    "docker"
    "libvirtd"
  ];

  services = {
    xserver.dpi = 109;
    printing = {
      enable = true;
    };
    nixseparatedebuginfod2.enable = true;
    udev.extraRules = ''
      # For RPi compute module (rpiboot)
      # 0a5c:2712 Broadcom Corp. BCM2712D0 Boot
      ATTRS{idVendor}=="0a5c", ATTRS{idProduct}=="2712", MODE="660", GROUP="plugdev", TAG+="uaccess"
    '';
  };

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
    # For widevine
    (pkgs.ungoogled-chromium.override { enableWideVine = true; })
    (pkgs.writeShellScriptBin "rewin" "sudo bootctl set-oneshot auto-windows; reboot")
    pkgs.rpiboot
  ]
  ++ (import ../packages/pc.nix args);

  hardware.firmware = [ pkgs.qcom-firmware-extract ];
}
