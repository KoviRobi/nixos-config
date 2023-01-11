{ pkgs, lib, config, ... }:
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

  # environment.etc."resolv.conf".enable = lib.mkForce false;
  services.resolved.enable = true;
  systemd.services."wsl_resolv".serviceConfig = { PassEnvironment = "WSL_INTEROP"; };
  systemd.services."wsl_resolv".wantedBy = [ "default.target" ];
  systemd.services."wsl_resolv".script = ''
    nameservers=($(/mnt/c/windows/System32/WindowsPowerShell/v1.0/powershell.exe \
      -Command "(Get-DnsClientServerAddress \
                      -AddressFamily IPv4 \
                ).ServerAddresses"))
    ${pkgs.systemd}/bin/resolvectl dns    eth0 $namesevers
    ${pkgs.systemd}/bin/resolvectl domain eth0 uk.cambridgeconsultants.com
    ${pkgs.systemd}/bin/resolvectl dnssec eth0 no
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
