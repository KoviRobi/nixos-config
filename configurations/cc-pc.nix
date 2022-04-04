# vim: set ts=2 sts=2 sw=2 et :
{ config, pkgs, lib, ... }@args:

{
  imports = [ ./cc.nix ../modules/initrd-ssh.nix ];

  services.xserver.dpi = 100;
  services.xserver.xrandrHeads = [
    { output = "DP-1"; }
    { output = "HDMI-2"; primary = true; monitorConfig = ''Option "BROADCAST_RGB" "1"''; }
  ];
  home-manager.users.default-user.xsession.initExtra = ''
    xrandr --output DP-1 --set 'Broadcast RGB' Full
  '';

  solarized.brightness = "light";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.xserver.videoDrivers = [ "i915" "modesetting" "nouveau" "fbdev" ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.supportedFilesystems = [ "cifs" ];

  networking.hostName = "rmk-nixos-a"; # Define your hostname.

  environment.systemPackages = with pkgs; [ barrier ]
    ++ (import ../packages/cc.nix args);
}
