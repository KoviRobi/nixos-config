# vim: set ts=2 sts=2 sw=2 et :
{ config, lib, pkgs, ... }:

{
  home-manager.users.default-user = {
    programs.git = {
      userName = lib.mkForce "Robert Kovacsics";
      userEmail = lib.mkForce "robert.kovacsics@carallon.com";
      lfs.enable = true;
    };
  };

  networking.domain = "office.carallon.com";

  nixpkgs.config = {
    allowUnfree = true;
    # Sigh, QT4 for SEGGER tools -- but I only use the cli tools anyway
    permittedInsecurePackages = [
      "segger-jlink-qt4-796s"
    ];
    segger-jlink.acceptLicense = true;
  };

  environment.systemPackages = [
    pkgs.segger-jlink
  ];

  security.pam.krb5.enable = false;
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
            "user"
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
  services.samba.package = pkgs.sambaFull;
  services.samba.settings = {
    global = {
      workgroup = "OFFICE";
      "passdb backend" = "tdbsam";
      printing = "cups";
      "printcap name" = "cups";
      "printcap cache time" = 750;
      "cups options" = "raw";
      "map to guest" = "Bad User";
      "usershare allow guests" = "No";
      "realm" = "OFFICE.CARALLON.COM";
      "security" = "ads";
      "template homedir" = "/home/%D/%U";
      "winbind refresh tickets" = true;
      "kerberos method" = "secrets and keytab";
      "dedicated keytab file" = "/etc/krb5.keytab";
      "client signing" = true;
      "client use spnego" = true;
    };
    homes = {
      "comment" = "Home Directories";
      "valid users" = "%S, %D%w%S";
      "browseable" = false;
      "read only" = false;
      "inherit acls" = true;
    };
    users = {
      "comment" = "All users";
      "path" = "/home";
      "read only" = false;
      "inherit acls" = true;
      "veto files" = "/aquota.user/groups/shares/";
    };
    groups = {
      "comment" = "All groups";
      "path" = "/home/groups";
      "read only" = false;
      "inherit acls" = true;
    };
    printers = {
      comment = "All Printers";
      path = "/var/tmp";
      printable = true;
      "create mask" = "0600";
      browseable = false;
    };
  };

  services.openssh.package = pkgs.opensshWithKerberos;
  services.openssh.settings.GSSAPIAuthentication = true;
  services.openssh.settings.GSSAPICleanupCredentials = true;
  services.openssh.settings.KerberosAuthentication = true;
  services.openssh.settings.KerberosTicketCleanup = true;
  services.openssh.settings.KerberosOrLocalPasswd = true;

  services.sssd.enable = true;
  services.sssd.config = ''
    [sssd]
    config_file_version = 2
    services = nss, pam
    domains = office.carallon.com

    [nss]

    [pam]

    [domain/office.carallon.com]
    auth_provider = krb5
    autofs_provider = ldap
    cache_credentials = false
    case_sensitive = true
    chpass_provider = krb5
    default_shell = ${lib.getExe pkgs.bashInteractive}
    enumerate = false
    fallback_homedir = /home/%u
    id_provider = ldap
    krb5_backup_server = bdc.office.carallon.com
    krb5_realm = OFFICE.CARALLON.COM
    krb5_server = pdc.office.carallon.com
    krb5_use_enterprise_principal = true
    ldap_account_expire_policy = ad
    ldap_force_upper_case_realm = true
    ldap_id_mapping = true
    ldap_krb5_init_creds = true
    ldap_referrals = false
    ldap_sasl_mech = GSSAPI
    ldap_schema = ad
    ldap_search_base = DC=office,DC=carallon,DC=com
    ldap_tls_reqcert = demand
    ldap_tls_reqcert = try
    ldap_uri = ldap://pdc.office.carallon.com
    ldap_uri = ldap://pdc.office.carallon.com,ldap://bdc.office.carallon.com
    ldap_use_tokengroups = true
  '';
}
