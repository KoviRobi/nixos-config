# vim: set ts=2 sts=2 sw=2 et :
{ config, lib, pkgs, ... }:

{ imports =
  [ ./base-configuration.nix
    ../modules/ssh.nix
    ../modules/graphical.nix
  ];

  services.xserver.dpi = 120;

  boot.initrd.availableKernelModules = [ "ata_piix" "mptspi" "uhci_hcd" "ehci_pci" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  virtualisation.vmware.guest.enable = true;
  virtualisation.docker.enable = true;

  networking.hostName = "cc-nixos-a"; # Define your hostname.

  krb5 =
  { enable = false;
    libdefaults = {
      default_realm = "UK.CAMBRIDGECONSULTANTS.COM";
       dns_lookup_realm = true;
       dns_lookup_kdc = true;
       forwardable = false;
       proxiable = false;
       renew_lifetime = 604800;
       ticket_lifetime = 86400;
       allow_weak_crypto = true;
    };
    realms = {
      "UK.CAMBRIDGECONSULTANTS.COM" = {
        master_kdc = "uk.cambridgeconsultants.com:88";
        kdc = "uk.cambridgeconsultants.com:88";
        admin_server = "uk.cambridgeconsultants.com";
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
        debug = true;
        ticket_lifetime = 50000;
        renew_lifetime = 100000;
        forwardable = true;
        krb4_convert = false;
        minimum_uid = 100;
      };
    };
    extraConfig = ''
      [logging]
       default = FILE:/var/log/krb5libs.log
       kdc = FILE:/var/log/krb5kdc.log
       admin_server = FILE:/var/log/kadmind.log
    '';
  };

  # services.xserver.displayManager.desktopManagerHandlesLidAndPower = false;
  services.xserver.synaptics =
  { enable = true;
    palmDetect = true;
    twoFingerScroll = true;
    additionalOptions =
    ''
      Option "CircularScrolling" "true"
    '';
  };
  services.xserver.inputClassSections = [ ''
    Identifier "touchpad catchall"
    Driver "synaptics"
    MatchIsTouchpad "on"
    MatchDevicePath "/dev/input/event*"
    Option "TapButton1" "1"
    Option "TapButton2" "2"
    Option "TapButton3" "3"
  '' ];
  services.xserver.xkbOptions = "caps:escape";

  nix.maxJobs = 4;
}
