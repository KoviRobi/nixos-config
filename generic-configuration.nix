# vim: set ts=2 sts=2 sw=2 et :
{ config, lib, pkgs, ... }:

{ imports =
  [ ./base-configuration.nix
    ./hardware-configuration-orfina.nix
    ./music.nix
    ./extra-grub.nix
    <nixpkgs/nixos/modules/profiles/base.nix>
    <nixpkgs/nixos/modules/profiles/all-hardware.nix>
  ];

  environment.etc."nixos/configuration.nix" =
  { source = "/etc/nixos/cl.cam.ac.uk.nix"; };

  environment.systemPackages = with pkgs; [ networkmanagerapplet ];
  networking.networkmanager = { enable = true; enableStrongSwan = true; };
}
