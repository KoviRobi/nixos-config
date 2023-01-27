{ config, lib, pkgs, ... }@args:
{
  wsl = {
    enable = true;
    nativeSystemd = true;
    defaultUser = "default-user";
    startMenuLaunchers = true;

    # Enable integration with Docker Desktop (needs to be installed)
    # docker.enable = true;

    interop = {
      register = true;
      preserveArgvZero = true;
    };

    wslConf.automount.root = "/mnt";
    wslConf.network.generateResolvConf = false;
    wslConf.network.hostname = config.networking.hostName;
  };

  services.resolved.enable = true;
  systemd.services."wsl_resolv".serviceConfig = {
    PassEnvironment = "WSL_INTEROP";
    Type = "oneshot";
    RemainAfterExit = true;
    ExecStop = "${pkgs.systemd}/bin/resolvectl revert eth0";
  };
  systemd.services."wsl_resolv".wantedBy = [ "default.target" ];
  systemd.services."wsl_resolv".script = ''
    IFS=$'\n\r '
    nameservers=($(/mnt/c/windows/System32/WindowsPowerShell/v1.0/powershell.exe \
      -Command "(Get-DnsClientServerAddress \
                      -AddressFamily IPv4 \
                ).ServerAddresses"))
    ${pkgs.systemd}/bin/resolvectl dns    eth0 "''${nameservers[@]}"
    ${pkgs.systemd}/bin/resolvectl domain eth0 uk.cambridgeconsultants.com
    ${pkgs.systemd}/bin/resolvectl dnssec eth0 no
  '';

  fonts.enableDefaultFonts = true;
  fonts.fonts = with pkgs; [
    noto-fonts
    dejavu_fonts
    liberation_ttf
    lmodern
    terminus-nerdfont
  ];

  systemd.user.targets.graphical-session.wantedBy = [ "default.target" ];
  systemd.user.services.wslg.wantedBy = [ "graphical-session-pre.target" ];
  systemd.user.services.wslg.before = [ "graphical-session.target" ];
  systemd.user.services.wslg.script = ''
    /run/current-system/systemd/bin/systemctl --user set-environment DISPLAY=:0
  '';

  services.xserver.dpi = 180;
  environment.systemPackages = with pkgs; [
    xorg.xauth
    config.boot.kernelPackages.usbip
  ] ++ (import ../packages/desktop-environment.nix args);

  systemd.user.sockets.ssh-agent.wantedBy = [ "default.target" ];
  systemd.user.sockets.ssh-agent.socketConfig = {
    ListenStream = [ "%t/keyring/ssh" ];
    Accept = true;
  };
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
  services.openssh.forwardX11 = true;
  solarized.brightness = "light";

  system.stateVersion = "22.05";
  home-manager.users.default-user.home.stateVersion = "18.09";
}
