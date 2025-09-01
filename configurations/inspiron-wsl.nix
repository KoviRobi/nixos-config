# vim: set ts=2 sts=2 sw=2 et :
{
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./base-configuration.nix
    (import ../modules/default-user.nix { })
    ../modules/ssh.nix
    ../packages/desktop-environment.nix
  ];

  fonts.enableDefaultPackages = true;
  fonts.packages = with pkgs; [
    noto-fonts
    dejavu_fonts
    liberation_ttf
    lmodern
    nerd-fonts.dejavu-sans-mono
    nerd-fonts.caskaydia-cove
    inconsolata
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
  };

  systemd.user.services.pulseaudio.enable = false;

  virtualisation.podman.enable = true;
  virtualisation.podman.dockerCompat = true;
}
