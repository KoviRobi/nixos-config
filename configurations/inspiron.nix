{ lib, pkgs, ... }:
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
    desktopManager.gnome.enable = true;
  };

  hardware.firmware = [ pkgs.qcom-firmware-extract ];
}
