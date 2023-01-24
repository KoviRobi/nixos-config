# vim: set ts=2 sts=2 sw=2 et :
{ config, pkgs, lib, ... }@args:

{
  imports = [
    ./cc.nix
    ../modules/initrd-ssh.nix
    ../modules/graphical.nix
  ];

  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;
  users.users.default-user.extraGroups = [ "docker" "libvirtd" ];

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

  environment.systemPackages = with pkgs; [ barrier virt-manager ]
    ++ (import ../packages/cc.nix args);

  services.udev.packages = with pkgs; [ openocd saleae-logic-2 ];

  services.udev.extraRules =
    ''
      ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6011", MODE="0666"
      DRIVER=="ftdi_sio", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6011", RUN+="${pkgs.bash}/bin/sh -c 'echo %k > /sys/bus/usb/drivers/ftdi_sio/unbind'"
    '';

  nix.sshServe.enable = true;
  nix.sshServe.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF8kc9byAsBL3Jt1zynOKBrDjp/Uwm774ymj3DoPNVSi root@cc-wsl"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINlxBXBCN14zoA3qmd31d/Nonaef5Cag4RKlsDlddFjJ mconway"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINBUSeOyKZcJ3KwQZ25dTdcAA0eJ75CbfXd2ToXiqrJB root@gitlab-runner.p3651"
  ];
  nix.settings.secret-key-files = "/etc/secrets/nix/secret-key";
  # Set modules/ssh.nix to not require authenticator key for nix-ssh
  users.users.nix-ssh.extraGroups = [ "no-google-authenticator" ];
}
