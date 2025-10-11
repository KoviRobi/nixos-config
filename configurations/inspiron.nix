{ pkgs, ... }:
{
  imports = [
    ./base-configuration.nix
    (import ../modules/default-user.nix { })
    ../modules/ssh.nix
    ../modules/graphical.nix
    ../modules/bluetooth.nix
    (import ../modules/avahi.nix { publish = false; })
  ];

  services = {
    xserver.dpi = 109;
    desktopManager.gnome.enable = true;
  };

  hardware.firmware = [ pkgs.qcom-firmware-extract ];
}
