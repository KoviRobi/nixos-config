{
  config,
  lib,
  pkgs,
  ...
}:
{
  wsl = {
    enable = true;
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
    nerd-fonts.terminess-ttf
  ];

  systemd.user = {
    targets.graphical-session.wantedBy = [ "default.target" ];
    services = {
      wslg = {
        serviceConfig.Type = "oneshot";
        wantedBy = [ "graphical-session-pre.target" ];
        before = [ "graphical-session.target" ];
        script = ''
          /run/current-system/systemd/bin/systemctl --user set-environment DISPLAY=:0
        '';
      };

      "ssh-agent@".serviceConfig = {
        # Workaround https://github.com/microsoft/WSL/issues/7591
        ExecStartPre = [
          "${pkgs.coreutils}/bin/mkdir -p /mnt/c/wsl/"
          "${pkgs.coreutils}/bin/install ${pkgs.pkgsCross.mingwW64.npiperelay}/bin/npiperelay.exe /mnt/c/wsl/npiperelay.exe"
        ];
        ExecStart = "/mnt/c/wsl/npiperelay.exe -ei -s '//./pipe/openssh-ssh-agent'";
        StandardInput = "socket";
      };
    };

    sockets.ssh-agent.wantedBy = [ "default.target" ];
    sockets.ssh-agent.socketConfig = {
      ListenStream = [ "%t/gcr/ssh" ];
      Accept = true;
    };
  };
  environment.systemPackages = with pkgs; [
    xauth
    config.boot.kernelPackages.usbip
    wl-clipboard
  ];

  networking.networkmanager.enable = lib.mkForce false;

  services = {
    resolved.enable = lib.mkForce false;
    gnome.gnome-keyring.enable = lib.mkForce false;
    tailscale.enable = lib.mkForce false;

    xserver.dpi = 180;
    openssh.settings.X11Forwarding = true;
    udev.enable = true;
  };

  security = {
    pam.services.login.enableGnomeKeyring = true;
    pam.services.sudo.enableGnomeKeyring = true;
  };

  users.users.default-user.extraGroups = [ "no-google-authenticator" ];

  home-manager.users.default-user = {
    services.gnome-keyring.enable = true;

    services.feh-random-background.enable = lib.mkForce false;
    services.udiskie.enable = lib.mkForce false;
    systemd.user.services.setxkbmap.Install.WantedBy = lib.mkForce [ ];
    systemd.user.services.xplugd.Install.WantedBy = lib.mkForce [ ];
    home.stateVersion = "24.11";
    programs.git.extraConfig.credential.helper =
      lib.mkForce "/mnt/c/Program\\ Files/Git/mingw64/bin/git-credential-manager.exe";
  };

  system.stateVersion = "22.05";
  home-manager.users.root.home.stateVersion = "24.11";
}
