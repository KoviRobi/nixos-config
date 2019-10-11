# vim: set ts=2 sts=2 sw=2 et :
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{ boot.loader.grub.extraEntries = ''
  menuentry "Guix" {
    search --set=drive1 --fs-uuid 8CF4-33C5
    configfile ($drive1)/grub/guix.cfg
  }
  '';
}
