{
  imports = [
    ./base-configuration.nix
    (import ../modules/default-user.nix { })
    ../modules/ssh.nix
    ../modules/graphical.nix
    (import ../modules/avahi.nix { publish = false; })
  ];

  services.xserver.dpi = 109;
}
