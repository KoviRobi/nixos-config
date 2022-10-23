{ pkgs, lib, config, ... }:
{
  wsl = {
    enable = true;
    automountPath = "/mnt";
    defaultUser = "default-user";
    startMenuLaunchers = true;

    # Enable integration with Docker Desktop (needs to be installed)
    # docker.enable = true;

    interop = {
      register = true;
      preserveArgvZero = false;
    };

    wslConf.network.generateResolvConf = false;
    wslConf.network.hostname = config.networking.hostName;
  };

  systemd.oomd.enable = false;

  environment.etc."resolv.conf".enable = lib.mkForce false;
  systemd.services."resolv.conf".serviceConfig = { PassEnvironment = "WSL_INTEROP"; };
  systemd.services."resolv.conf".wantedBy = [ "default.target" ];
  systemd.services."resolv.conf".script = ''
    /mnt/c/windows/System32/WindowsPowerShell/v1.0/powershell.exe \
      -Command "(Get-DnsClientServerAddress \
                      -AddressFamily IPv4 \
                ).ServerAddresses" |
      ${pkgs.dos2unix}/bin/dos2unix |
      ${pkgs.gnused}/bin/sed 's/^/nameserver /' > /etc/resolv.conf
  '';

  systemd.services.display-manager.serviceConfig = {
    PassEnvironment = "WSL_INTEROP";
    Type = "exec";
    User = "${config.users.users.default-user.name}";
    ExecStop = lib.mkForce ''
      "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe" -Command '& { Stop-Process -Name vcxsrv ; Wait-Process -Name vcxsrv }'
    '';
    ExecStartPre = lib.mkForce ''
      -"/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe" -Command '& { Stop-Process -Name vcxsrv ; Wait-Process -Name vcxsrv }'
    '';
  };
  systemd.services.display-manager.script = lib.mkForce ''
    ${pkgs.xorg.xauth}/bin/xauth add _gateway:1 . $(${pkgs.util-linux}/bin/mcookie)
    "/mnt/c/Program Files/VcXsrv/vcxsrv.exe" :1 -multiwindow -clipboard -wgl -auth $(/bin/wslpath -w ~)/.Xauthority -logfile $(/bin/wslpath -w /tmp)/X.log
  '';
  services.xserver.dpi = 180;
  environment.systemPackages = with pkgs; [ xorg.xauth ];

  systemd.user.services.gnome-keyring.script = ''${pkgs.gnome.gnome-keyring}/bin/gnome-keyring-daemon --start'';
  systemd.user.services.gnome-keyring.wantedBy = [ "default.target" ];

  users.users.default-user.extraGroups = [ "no-google-authenticator" ];
  services.openssh.forwardX11 = true;
  solarized.brightness = "light";

  system.stateVersion = "22.05";
  home-manager.users.default-user.home.stateVersion = "18.09";
}
