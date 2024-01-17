# vim: set ts=2 sts=2 sw=2 et :
{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./base-configuration.nix
      (import ../modules/default-user.nix {
        name = "rmk";
        user-options = { uid = 1000; };
        group-options = { gid = 1000; };
      }
      )
      ../modules/ssh.nix
    ];

  environment.etc.hosts.enable = lib.mkForce false;

  solarized.brightness = "light";

  users.users.default-user.extraGroups = [ "docker" "build" "wireshark" ];
  environment.systemPackages = with pkgs; [
    docker-credential-helpers
    amazon-ecr-credential-helper
    sigrok-cli
    pulseview
  ];

  nixpkgs.config.allowUnfree = true; # For VSCode
  home-manager.users.default-user = {
    programs.git = {
      userName = lib.mkForce "Robert Kovacsics";
      userEmail = lib.mkForce "robert.kovacsics@cambridgeconsultants.com";
      extraConfig.http.emptyauth = true;
      lfs.enable = true;
    };
  };

  # Often docker images use a `build` user
  users.users.build = {
    isSystemUser = true;
    isNormalUser = false;
    group = "build";
    shell = "${pkgs.coreutils}/bin/false";
  };
  users.groups.build = { };

  security.krb5 =
    {
      enable = true;
      settings = {
        libdefaults = {
          default_realm = "UK.CAMBRIDGECONSULTANTS.COM";
          dns_lookup_realm = true;
          dns_lookup_kdc = true;
          forwardable = false;
          proxiable = false;
        };
        realms = {
          "UK.CAMBRIDGECONSULTANTS.COM" = {
            admin_server = "uk.cambridgeconsultants.com";
            kdc = "uk.cambridgeconsultants.com:88";
            master_kdc = "uk.cambridgeconsultants.com:88";
            default_domain = "uk.cambridgeconsultants.com";
          };
        };
        domain_realm = {
          ".uk.cambridgeconsultants.com" = "UK.CAMBRIDGECONSULTANTS.COM";
          ".cambridgeconsultants.com" = "UK.CAMBRIDGECONSULTANTS.COM";
          "cambridgeconsultants.com" = "UK.CAMBRIDGECONSULTANTS.COM";
          "uk.cambridgeconsultants.com" = "UK.CAMBRIDGECONSULTANTS.COM";
        };
        appdefaults = {
          pam = {
            debug = false;
            ticket_lifetime = 36000;
            renew_lifetime = 36000;
            forwardable = true;
            krb4_convert = false;
          };
        };
        logging = {
          default = FILE:/var/log/krb5libs.log;
          kdc = FILE:/var/log/krb5kdc.log;
          admin_server = FILE:/var/log/kadmind.log;
        };
      };
    };

  fileSystems = builtins.listToAttrs
    (map
      (remote-local: {
        name = remote-local.local;
        value = {
          device = "//csp05na.uk.cambridgeconsultants.com/${remote-local.remote}";
          fsType = "cifs";
          options = [
            "username=rmk"
            "domain=CCL"
            "uid=${toString config.users.users.default-user.uid}"
            "gid=${toString config.users.groups.default-user.gid}"
            "noauto"
          ];
        };
      })
      [
        { remote = "home3/rmk"; local = "/cc/user"; }
        { remote = "projects"; local = "/cc/projects"; }
        { remote = "transit"; local = "/cc/transit"; }
        { remote = "closed"; local = "/cc/closed"; }
        { remote = "install"; local = "/cc/install"; }
      ]);

  services.udev.extraRules =
    ''
      SUBSYSTEM=="usb", ATTRS{idVendor}=="1366", ATTRS{manufacturer}=="SEGGER", ATTRS{idProduct}=="0101", ATTRS{product}=="J-Link", MODE="0666"
      ACTION=="add", ATTRS{serial}=="DK5XA9SZ", ATTRS{manufacturer}=="FTDI", SYMLINK+="ttyBLE"
      ACTION=="add", ATTRS{serial}=="DK6N5V3E", ATTRS{manufacturer}=="FTDI", SYMLINK+="ttyASIC"

      ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6011", MODE="0666"
      DRIVER=="ftdi_sio", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6011", RUN+="${pkgs.bash}/bin/sh -c 'echo %k > /sys/bus/usb/drivers/ftdi_sio/unbind'"

      DRIVER=="usb", ATTRS{product}=="p11-Bjongle BLE adapter", OWNER="${config.users.users.default-user.name}", SYMLINK+="bjongle-$attr{serial}"
    '';
  services.udev.packages = with pkgs; [ saleae-logic-2 libsigrok ];
}
