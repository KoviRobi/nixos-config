# vim: set ts=2 sts=2 sw=2 et :
{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./base-configuration.nix
      ../modules/graphical.nix
      (import ../modules/default-user.nix { })
      ../modules/ssh.nix
    ];

  services.openssh.ports = [ 22 2233 ];

  systemd.user.services.pulseaudio.enable = false;
  hardware.pulseaudio.extraClientConf = ''
    default-server = _gateway;
  '';

  programs.atop.netatop.enable = lib.mkForce false;

  home-manager.users.default-user = {
    programs.git = {
      userName = lib.mkForce "Robert Kovacsics";
      userEmail = lib.mkForce "robertkovacsics@carallon.com";
      lfs.enable = true;
    };
  };

  services.xserver.enable = lib.mkForce false;
  services.xserver.displayManager.lightdm.enable = lib.mkForce false;
  services.xserver.windowManager.i3.enable = lib.mkForce false;

  security.krb5 =
    {
      enable = true;
      settings = {
        libdefaults = {
          # "dns_canonicalize_hostname" and "rdns" are better set to false for improved security.
          # If set to true, the canonicalization mechanism performed by Kerberos client may
          # allow service impersonification, the consequence is similar to conducting TLS certificate
          # verification without checking host name.
          # If left unspecified, the two parameters will have default value true, which is less secure.
          rdns = false;
          #Set to true so DNS+GSSAPI works
          dns_canonicalize_hostname = true;
          default_realm = "OFFICE.CARALLON.COM";
        };

        realms = {
          "OFFICE.CARALLON.COM" = {
            kdc = [
              #PDC & BDC - misspiggy & floyd at time of writing
              "pdc.office.carallon.com"
              "bdc.office.carallon.com"
              #Old PDC & BDC - will stop working soon(ish)
              "kermit.office.carallon.com"
              "fozzie.office.carallon.com"
            ];
            #Mark PDC
            admin_server = "pdc.office.carallon.com";
            master_kdc = "pdc.office.carallon.com";
          };

          domain_realm = {
            ".carallon.com" = "OFFICE.CARALLON.COM";
            "carallon.com" = "OFFICE.CARALLON.COM";
            ".CARALLON.COM" = "OFFICE.CARALLON.COM";
            "CARALLON.COM" = "OFFICE.CARALLON.COM";
          };

          logging = {
            kdc = "FILE:/var/log/krb5/krb5kdc.log";
            admin_server = "FILE:/var/log/krb5/kadmind.log";
            default = "SYSLOG:NOTICE:DAEMON";
          };
        };
      };
    };

  fileSystems = builtins.listToAttrs
    (map
      (remote-local: {
        name = remote-local.local;
        value = {
          device = "//kermit.office.carallon.com/${remote-local.remote}";
          # //kermit.office.carallon.com/net_share   /kermit/net_share   cifs   defaults,nofail,uid=ali,gid=ali,user=alil,vers=2.1
          fsType = "cifs";
          options = [
            "username=robertkovacsics"
            "uid=${toString config.users.users.default-user.uid}"
            "gid=${toString config.users.groups.default-user.gid}"
            "noauto"
          ];
        };
      })
      [
        { remote = "net_share"; local = "/carallon/net_share"; }
        { remote = "scratch"; local = "/carallon/scratch"; }
      ]);

  security.wrappers = {
    "mount.cifs" = { setuid = true; owner = "root"; group = "root"; source = "${pkgs.cifs-utils}/bin/mount.cifs"; };
  };
  services.samba.enable = true;
}
