# vim: set ts=2 sts=2 sw=2 et :
{ config, pkgs, lib, ... }@args:
let HOME = config.users.users.default-user.home;
in
{
  nix.gc = {
    automatic = true;
    dates = "weekly";
  };

  imports = [
    (import ../modules/linux-console.nix { })
    ../modules/home-manager.nix
    ../modules/solarized.nix
    ../modules/shell.nix
    ../modules/nethogs.nix
    ../modules/vim.nix
    ../modules/clipboard.nix

    ../packages/network.nix
  ];

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = { LC_TIME = "en_DK.UTF-8"; };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableBashCompletion = true;
  };

  programs.nix-ld.enable = true;
  programs.nix-ld.package = pkgs.nix-ld-rs;
  programs.nix-ld.libraries = [ pkgs.gtk3 pkgs.gtk2 pkgs.cairo pkgs.glib ];

  programs.nix-ld-32.enable = true;
  programs.nix-ld-32.package = pkgs.pkgsi686Linux.nix-ld-rs;
  programs.nix-ld-32.libraries = [ pkgs.pkgsi686Linux.gtk3 pkgs.pkgsi686Linux.gtk2 pkgs.pkgsi686Linux.cairo pkgs.pkgsi686Linux.glib ];

  programs.xonsh.enable = true;
  programs.bandwhich.enable = true;
  programs.atop = {
    enable = true;
    atopService.enable = true;
    netatop.enable = true;
    setuidWrapper.enable = true;
  };

  environment.homeBinInPath = true;
  environment.systemPackages =
    (import ../packages/base.nix args) ++
    (import ../packages/better-cli-tools.nix args);

  documentation.enable = true;
  documentation.man.enable = true;
  documentation.man.generateCaches = true;
  documentation.info.enable = true;
  documentation.dev.enable = true;
  documentation.nixos.enable = true;

  #sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.bluetooth.enable = true;

  boot.kernel.sysctl."kernel.sysrq" = 1;
  boot.kernel.sysctl."kernel.dmesg_restrict" = 0;
  boot.kernelParams = [ "boot.shell_on_fail" ];

  services =
    {
      earlyoom.enable = true;
      clamav = { daemon.enable = true; updater.enable = true; };
    };

  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPorts = [ ];

  networking.networkmanager = { enable = true; enableStrongSwan = true; };
  systemd.services.NetworkManager-wait-online.serviceConfig.ExecStart =
    [ "" "${pkgs.networkmanager}/bin/nm-online -q" ];

  systemd.services.systemd-udev-settle.enable = false;
  systemd.services.ModemManager.enable = false;
  systemd.coredump.enable = true;

  services.dbus.packages = with pkgs; [ gcr ];
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.sudo.enableGnomeKeyring = true;
  environment.etc."sudo.conf".text = ''
    Path askpass ${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass
  '';

  services.udev.extraRules =
    ''
      SUBSYSTEM=="tty", ATTRS{manufacturer}=="KoviRobi", ATTRS{product}=="Custom steno", SYMLINK="KoviRobi-Steno"
      ACTION=="add", SUBSYSTEM=="usb", ATTR{manufacturer}=="Gabotronics", GROUP="plugdev", MODE="0664", SYMLINK+="XScope%n"
    '';
  services.udev.packages = with pkgs; [ openocd picotool libsigrok ];

  services.tailscale.enable = true;
  services.resolved.enable = true;

  # To make tailscale work
  networking.firewall.checkReversePath = "loose";

  programs.command-not-found.enable = false; # Using nix-index

  environment.extraOutputsToInstall = [ "terminfo" ];
}
