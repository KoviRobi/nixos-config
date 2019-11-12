# vim: set ts=2 sts=2 sw=2 et :
{ config, lib, pkgs, ... }:

{ environment.systemPackages = [ pkgs.google-authenticator ];
  security.pam.services.sshd.googleAuthenticator.enable = true;
  services.openssh =
  { enable = true;
    permitRootLogin = "no";
    extraConfig = "AuthenticationMethods publickey,keyboard-interactive";
  };
}
