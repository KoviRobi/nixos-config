# vim: set ts=2 sts=2 sw=2 et :
{ config, pkgs, lib, ... }:

{
  home-manager.useUserPackages = true;
  home-manager.users.default-user = { ... }: {
    imports = [ ../home ];
    nixpkgs.overlays = config.nixpkgs.overlays;
    nixos = {
      services.xserver.dpi = config.services.xserver.dpi;
      fileSystems = config.fileSystems;
      users.users.default-user.uid = config.users.users.default-user.uid;
    };
  };
  home-manager.users.root = { ... }: {
    imports = [ ../home/shell.nix ];
  };
}
