# vim: set ts=2 sts=2 sw=2 et :
{ config, pkgs, lib, ... }@args:
let
  HOME = config.users.users.default-user.home;
in
{
  nix.nixPath = [
    "nixpkgs=/nix/pkgs"
    "nixos-config=${HOME}/nixos/configuration.nix"
    "home-manager=${HOME}/programming/nix/home-manager"
    "/nix/pkgs"
  ];
}
