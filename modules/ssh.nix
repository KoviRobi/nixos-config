# vim: set ts=2 sts=2 sw=2 et :
{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.google-authenticator ];
  security.pam.services.sshd.google-authenticator.enable = true;
  users.groups.no-google-authenticator = { };
  services.openssh =
    {
      enable = true;
      permitRootLogin = "no";
      extraConfig = ''
        Match Group !no-google-authenticator,*
          AuthenticationMethods publickey,keyboard-interactive
        Match All
      '';
    };
}
