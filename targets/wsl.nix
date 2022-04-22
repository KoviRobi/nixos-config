{ pkgs, lib, config, ... }:
{
  wsl = {
    enable = true;
    automountPath = "/mnt";
    defaultUser = "rmk";
    startMenuLaunchers = true;

    # Enable integration with Docker Desktop (needs to be installed)
    # docker.enable = true;

    wslConf.network.generateResolvConf = "false";
    wslConf.network.hostname = config.networking.hostName;
  };
  environment.etc."resolv.conf".enable = lib.mkForce true;
  environment.etc."resolv.conf".text = ''
    nameserver 1.1.1.1
    nameserver 8.8.8.8
  '';
  users.users.default-user.extraGroups = [ "no-google-authenticator" ];
  services.xserver.dpi = 100;
  environment.systemPackages = with pkgs; [ xorg.xauth ];
  services.openssh.forwardX11 = true;
  solarized.brightness = "light";
}
