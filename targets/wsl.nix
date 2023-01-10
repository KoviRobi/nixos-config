{ pkgs, lib, config, ... }:
{
  wsl = {
    enable = true;
    defaultUser = "default-user";
    startMenuLaunchers = true;

    # Enable integration with Docker Desktop (needs to be installed)
    # docker.enable = true;

    interop = {
      register = true;
      preserveArgvZero = false;
    };

    wslConf.automount.root = "/mnt";
    wslConf.network.generateResolvConf = false;
    wslConf.network.hostname = config.networking.hostName;
  };

  systemd.oomd.enable = false;

  environment.etc."resolv.conf".enable = lib.mkForce false;
  systemd.services."resolv.conf".serviceConfig = { PassEnvironment = "WSL_INTEROP"; };
  systemd.services."resolv.conf".wantedBy = [ "default.target" ];
  systemd.services."resolv.conf".script = ''
    echo 'search badger-toad.ts.net kovirobi.github.beta.tailscale.net uk.cambridgeconsultants.com' > /etc/resolv.conf
    echo 'nameserver 100.100.100.100' >> /etc/resolv.conf
    /mnt/c/windows/System32/WindowsPowerShell/v1.0/powershell.exe \
      -Command "(Get-DnsClientServerAddress \
                      -AddressFamily IPv4 \
                ).ServerAddresses" |
      ${pkgs.dos2unix}/bin/dos2unix |
      ${pkgs.gnused}/bin/sed 's/^/nameserver /' >> /etc/resolv.conf
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
