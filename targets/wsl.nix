{ pkgs, lib, config, ... }:
{
  wsl = {
    enable = true;
    automountPath = "/mnt";
    defaultUser = "default-user";
    startMenuLaunchers = true;

    # Enable integration with Docker Desktop (needs to be installed)
    # docker.enable = true;

    wslConf.network.generateResolvConf = "false";
    wslConf.network.hostname = config.networking.hostName;
  };

  systemd.services."resolv.conf".serviceConfig = { PassEnvironment = "WSL_INTEROP"; };
  systemd.services."resolv.conf".wantedBy = [ "default.target" ];
  systemd.services."resolv.conf".script = ''
    /mnt/c/windows/System32/WindowsPowerShell/v1.0/powershell.exe \
      -Command "(Get-DnsClientServerAddress \
                      -InterfaceAlias Ethernet \
                      -AddressFamily IPv4 \
                ).ServerAddresses" |
      ${pkgs.dos2unix}/bin/dos2unix |
      ${pkgs.gnused}/bin/sed 's/^/nameserver /' > /etc/resolv.conf
  '';
  users.users.default-user.extraGroups = [ "no-google-authenticator" ];
  services.xserver.dpi = 100;
  environment.systemPackages = with pkgs; [ xorg.xauth ];
  services.openssh.forwardX11 = true;
  solarized.brightness = "light";
}
