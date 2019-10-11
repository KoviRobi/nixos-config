# vim: set ts=2 sts=2 sw=2 et :
{ config, lib, pkgs, ... }:

{ imports =
  [ ./base-configuration.nix
    ./hardware-configuration.nix.virtualbox
    ./ssh.nix
    (import ./avahi.nix { publish = false; })
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  environment.etc."nixos/configuration.nix" =
  { source = "/etc/nixos/virtualbox-configuration.nix"; };

  environment.systemPackages = with pkgs; [ networkmanagerapplet ];
  networking.hostName = "C930";
  networking.networkmanager = { enable = true; enableStrongSwan = true; };

  system.stateVersion = "19.03"; # Did you read the comment?
}
