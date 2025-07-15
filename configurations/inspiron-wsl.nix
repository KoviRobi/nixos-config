# vim: set ts=2 sts=2 sw=2 et :
{
  lib,
  ...
}:

{
  imports = [
    ./base-configuration.nix
    ../modules/graphical.nix
    (import ../modules/default-user.nix { })
    ../modules/ssh.nix
  ];

  nixpkgs.config.allowUnfree = true;

  services = {
    openssh.ports = [
      22
      2233
    ];

    pulseaudio.extraClientConf = ''
      default-server = _gateway;
    '';

    xserver = {
      enable = lib.mkForce false;
      displayManager.lightdm.enable = lib.mkForce false;
      windowManager.i3.enable = lib.mkForce false;
    };
  };

  programs = {
    atop.netatop.enable = lib.mkForce false;
  };
  documentation.man.generateCaches = lib.mkForce true;

  systemd.user.services.pulseaudio.enable = false;

  virtualisation.podman.enable = true;
  virtualisation.podman.dockerCompat = true;
}
