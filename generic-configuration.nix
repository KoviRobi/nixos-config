# vim: set ts=2 sts=2 sw=2 et :
{ config, lib, pkgs, ... }:

{ imports =
  [ ./base-configuration.nix
    ./hardware-configuration-orfina.nix
    ./extra-grub.nix
    <nixpkgs/nixos/modules/profiles/base.nix>
    <nixpkgs/nixos/modules/profiles/all-hardware.nix>
    (import ./music.nix { music-fs-uuid = "b5cb1ef0-7603-4d71-b107-c5ab11c76e17"; })
  ];

  environment.etc."nixos/configuration.nix" =
  { source = "/etc/nixos/generic-configuration.nix"; };

  environment.systemPackages = with pkgs; [ networkmanagerapplet ];
  networking.networkmanager = { enable = true; enableStrongSwan = true; };

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "nodev"; # or "nodev" for efi only

  boot.extraModulePackages = with pkgs.linuxPackages; [ rtl8812au ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.03"; # Did you read the comment?
}
