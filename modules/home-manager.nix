# vim: set ts=2 sts=2 sw=2 et :
{ config, pkgs, lib, ... }:

if (builtins.tryEval <home-manager>).success
then
  {
    imports = [ <home-manager/nixos> ];

    home-manager.useUserPackages = true;
    home-manager.users.default-user = { ... }: {
      imports = [ ../home ];
      nixpkgs.overlays = config.nixpkgs.overlays;
      nixos = {
        services.xserver.dpi = config.services.xserver.dpi;
        fileSystems = config.fileSystems;
      };
    };
  }
else builtins.trace "Home manager not found in <home-manager>, ignoring" { }
