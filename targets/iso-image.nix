# nix build -f <nixpkgs/nixos> config.system.build.isoImage -I nixos-config=iso.nix
{ config, pkgs, ... }:

let mypkgs = import ./pkgs/all-packages.nix { nixpkgs = pkgs; };
in
{
  imports =
  [ <nixpkgs/nixos/modules/installer/cd-dvd/iso-image.nix>
    <nixpkgs/nixos/modules/profiles/base.nix>
  ];
}
