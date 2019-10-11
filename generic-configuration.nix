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

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  #boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only
  boot.loader.grub.device = "nodev"; # or "nodev" for efi only

  boot.extraModulePackages = with pkgs.linuxPackages; [ rtl8812au ];
}
