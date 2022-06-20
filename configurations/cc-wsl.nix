# vim: set ts=2 sts=2 sw=2 et :
{ config, lib, pkgs, ... }:

{
  imports = [ ./cc.nix ];
  wsl.wslConf.network.generateHosts = "false";
}
