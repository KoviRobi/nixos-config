# vim: set ts=2 sts=2 sw=2 et :
{ config, pkgs, lib, ... }:

if (builtins.tryEval <home-manager>).success
then
{ imports = [ <home-manager/nixos> ];

  home-manager.useUserPackages = true;
  home-manager.users.default-user = { ... }: {
    imports = [ ../home ];
    nixpkgs.overlays = config.nixpkgs.overlays;
    dpi = config.services.xserver.dpi;
    fileSystems = pkgs.lib.mapAttrsToList (k: v: k) config.fileSystems;
  };
}
else builtins.trace "Home manager not found in <home-manager>, ignoring" {}
