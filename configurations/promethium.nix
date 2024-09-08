# vim: set ts=2 sts=2 sw=2 et :
{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./base-configuration.nix
      ./carallon.nix
      ../modules/graphical.nix
      (import ../modules/default-user.nix { })
      ../modules/ssh.nix
      ../modules/graphical.nix
      ../modules/initrd-ssh.nix
      (import ../modules/git-appraise-rob.nix { auth = true; publish = true; })
    ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "saleae-logic-2"
    "saleae-logic"
  ];

  boot.initrd.network.flushBeforeStage2 = false;
  initrd-ssh.interface = "enp0s31f6";
  initrd-ssh.udhcpcExtraArgs = [ "-t 10" "-b" "-x" "61:0130d042ec62ef" ];
  systemd.targets.emergency.wants = [ "sshd.service" ];

  solarized.brightness = "light";

  services.xserver.dpi = 93;

  virtualisation.podman.enable = true;
  virtualisation.podman.dockerCompat = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.qemu.ovmf.packages = [ pkgs.OVMFFull.fd ];
  virtualisation.libvirtd.qemu.vhostUserPackages = [ pkgs.virtiofsd ];
  virtualisation.libvirtd.qemu.swtpm = { enable = true; };
  users.users.default-user.extraGroups = [ "scanner" "lp" "docker" "libvirtd" ];

  environment.systemPackages = with pkgs; [
    virt-manager
    virtiofsd
    swtpm
    sigrok-cli
    pulseview
    saleae-logic-2
    google-chrome
  ];
  services.udev.packages = with pkgs; [ saleae-logic-2 ];

  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplip ];
  services.printing.bindirCmds = ''
    mkdir -p $out/lib/cups/backend
    ln -sf ${pkgs.writeShellScript "smb-krb5" ''
      export DEVICE_URI=smb://''${DEVICE_URI#smb_krb5://}
      ${pkgs.sambaFull}/libexec/samba/smbspool_krb5_wrapper "$@"
    ''} $out/lib/cups/backend/smb_krb5
  '';

  programs.systemtap.enable = true;
}
