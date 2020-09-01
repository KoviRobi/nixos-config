# vim: set ts=2 sts=2 sw=2 et :
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs;
    [
      gcc
      gnumake
      binutils
      rlwrap
      (python3.withPackages (p: with p; [ matplotlib numpy pandas ]))
      guile
    ] ++
    (with ocamlPackages_latest; [ ocaml utop merlin seq ocp-indent ]);
}
