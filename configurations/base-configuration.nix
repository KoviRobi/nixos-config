# vim: set ts=2 sts=2 sw=2 et :
{ config, pkgs, lib, ... }@args:
let HOME = config.users.users.default-user.home;
in
{
  nixpkgs.overlays = map
    (x: import (../overlays + ("/" + x)))
    (with builtins; attrNames (readDir ../overlays));
  nix.nixPath = [
    "nixpkgs=${HOME}/programming/nix/pkgs/unstable"
    "nixos-config=${HOME}/nixos/configuration.nix"
    "home-manager=${HOME}/programming/nix/home-manager"
    "${HOME}/programming/nix/pkgs/unstable"
  ];

  imports = [
    (import ../modules/linux-console.nix { })
    ../modules/home-manager.nix
  ];

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = { LC_TIME = "en_DK"; };

  services.localtime.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableBashCompletion = true;
  };

  environment.homeBinInPath = true;
  environment.systemPackages =
    (import ../packages/base.nix args)
    ++ (import ../packages/desktop-environment.nix args);

  fonts.fonts = with pkgs; [ noto-fonts dejavu_fonts lmodern ];

  documentation.dev.enable = true;

  #sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.bluetooth =
    {
      enable = true;
      package = pkgs.bluezFull;
    };

  boot.kernel.sysctl."kernel.sysrq" = 1;
  boot.kernelParams = [ "boot.shell_on_fail" ];

  services =
    {
      earlyoom.enable = true;
      clamav = { daemon.enable = true; updater.enable = true; };
    };

  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPorts = [ ];

  networking.networkmanager = { enable = true; enableStrongSwan = true; };

  systemd.services.systemd-udev-settle.enable = false;
  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.services.ModemManager.enable = false;

  services.dbus.packages = with pkgs; [ gcr ];
  services.gnome3.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.sudo.enableGnomeKeyring = true;

  services.udev.extraRules =
    ''
      SUBSYSTEM=="tty", ATTRS{manufacturer}=="KoviRobi", ATTRS{product}=="Custom steno", SYMLINK="KoviRobi-Steno"
    '';
}
