# vim: set ts=2 sts=2 sw=2 et :
{ config, pkgs, lib, ... }@args:

{
  imports = [
    ./cc.nix
    ../modules/initrd-ssh.nix
    ../modules/graphical.nix
  ];

  virtualisation.docker.enable = true;

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

  services.openssh.forwardX11 = true;

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.supportedFilesystems = [ "cifs" ];

  environment.systemPackages = with pkgs; [ barrier ]
    ++ (import ../packages/cc.nix args);

  services.udev.packages = with pkgs; [ openocd saleae-logic-2 ];

  nix.sshServe.enable = true;
  nix.sshServe.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF8kc9byAsBL3Jt1zynOKBrDjp/Uwm774ymj3DoPNVSi root@cc-wsl"
  ];
  # Set modules/ssh.nix to not require authenticator key for nix-ssh
  users.users.nix-ssh.extraGroups = [ "no-google-authenticator" ];
}
