# vim: set ts=2 sts=2 sw=2 et :
{ publish ? true }:
{ config, pkgs, ... }:

{ environment.systemPackages = [ pkgs.avahi ];
  services.avahi =
  { enable = true;
    nssmdns = true;
    publish.enable = publish;
    publish.addresses = publish;
  };
}
