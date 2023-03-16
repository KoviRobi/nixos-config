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
    { output = "HDMI-1"; primary = true; monitorConfig = ''Option "BROADCAST_RGB" "1"''; }
  ];
  home-manager.users.default-user.xsession.initExtra = ''
    xrandr --output DP-1 --set 'Broadcast RGB' Full
  '';

  solarized.brightness = "light";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.xserver.videoDrivers = [ "i915" "modesetting" "nouveau" "fbdev" ];

  services.openssh.settings.X11Forwarding = true;

  initrd-ssh.interface = "eno1";
  initrd-ssh.udhcpcExtraArgs = [ "-t 10" "-b" ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.supportedFilesystems = [ "cifs" ];

  environment.systemPackages = with pkgs; [ virt-manager saleae-logic-2 ]
    ++ (import ../packages/cc.nix args);

  nix.sshServe.enable = true;
  nix.sshServe.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF8kc9byAsBL3Jt1zynOKBrDjp/Uwm774ymj3DoPNVSi root@cc-wsl"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOJmB7G9x+o9JKKtUXzzI7cuyoN2yY1h6PQjXpGtZJ+8 root@rmk-cc-b"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINlxBXBCN14zoA3qmd31d/Nonaef5Cag4RKlsDlddFjJ mconway"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINBUSeOyKZcJ3KwQZ25dTdcAA0eJ75CbfXd2ToXiqrJB root@gitlab-runner.p3651"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDCkYPC+gZP1YuLReyD05ZJaGbo4BMcI/D8RyiQd4BNh wwykeham@wpwlx1"
  ];
  nix.settings.secret-key-files = "/etc/secrets/nix/secret-key";
  # Set modules/ssh.nix to not require authenticator key for nix-ssh
  users.users.nix-ssh.extraGroups = [ "no-google-authenticator" ];
}
