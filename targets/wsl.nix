{ config, lib, pkgs, ... }:
{
  wsl = {
    enable = true;
    nativeSystemd = true;
    defaultUser = "default-user";
    startMenuLaunchers = true;

    # Enable integration with Docker Desktop (needs to be installed)
    # docker.enable = true;

    interop.register = true;

    wslConf.automount.root = "/mnt";
    wslConf.network.hostname = config.networking.hostName;

    useWindowsDriver = true;
  };

  imports = [ ../packages/desktop-environment.nix ];

  fonts.enableDefaultPackages = true;
  fonts.packages = with pkgs; [
    noto-fonts
    dejavu_fonts
    liberation_ttf
    lmodern
    terminus-nerdfont
  ];

  systemd.user.targets.graphical-session.wantedBy = [ "default.target" ];
  systemd.user.services.wslg.serviceConfig.Type = "oneshot";
  systemd.user.services.wslg.wantedBy = [ "graphical-session-pre.target" ];
  systemd.user.services.wslg.before = [ "graphical-session.target" ];
  systemd.user.services.wslg.script = ''
    /run/current-system/systemd/bin/systemctl --user set-environment DISPLAY=:0
  '';

  services.xserver.dpi = 180;
  environment.systemPackages = with pkgs; [
    xorg.xauth
    config.boot.kernelPackages.usbip
  ];

  systemd.user.sockets.ssh-agent.wantedBy = [ "default.target" ];
  systemd.user.sockets.ssh-agent.socketConfig = {
    ListenStream = [ "%t/keyring/ssh" ];
    Accept = true;
  };
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.sudo.enableGnomeKeyring = true;
  home-manager.users.default-user.services.gnome-keyring.enable = true;
  systemd.user.services."ssh-agent@".serviceConfig = {
    # Workaround https://github.com/microsoft/WSL/issues/7591
    ExecStartPre = [
      "${pkgs.coreutils}/bin/mkdir -p /mnt/c/wsl/"
      "${pkgs.coreutils}/bin/install ${pkgs.pkgsCross.mingwW64.npiperelay}/bin/npiperelay.exe /mnt/c/wsl/npiperelay.exe"
    ];
    ExecStart = "/mnt/c/wsl/npiperelay.exe -ei -s '//./pipe/openssh-ssh-agent'";
    StandardInput = "socket";
  };

  users.users.default-user.extraGroups = [ "no-google-authenticator" ];
  services.openssh.settings.X11Forwarding = true;

  home-manager.users.default-user.services.feh-random-background.enable = lib.mkForce false;
  home-manager.users.default-user.systemd.user.services.setxkbmap.Install.WantedBy = lib.mkForce [ ];
  home-manager.users.default-user.systemd.user.services.xplugd.Install.WantedBy = lib.mkForce [ ];

  system.stateVersion = "22.05";
  home-manager.users.default-user.home.stateVersion = "18.09";
  home-manager.users.root.home.stateVersion = "23.05";
  home-manager.users.default-user.programs.git.extraConfig.credential.helper = lib.mkForce "/mnt/c/Program\\ Files/Git/mingw64/bin/git-credential-manager.exe";

  services.udev.enable = true;
}
