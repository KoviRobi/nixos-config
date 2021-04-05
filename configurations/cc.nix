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
      ../modules/graphical.nix
    ];

  services.xserver.dpi = 120;

  boot.initrd.availableKernelModules = [ "ata_piix" "mptspi" "uhci_hcd" "ehci_pci" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  virtualisation.vmware.guest = { enable = true; };
  virtualisation.docker.enable = true;
  users.users.default-user.extraGroups = [ "docker" "build" "wireshark" ];
  environment.systemPackages = with pkgs; [ docker-credential-helpers ];
  programs.wireshark.enable = true;
  programs.wireshark.package = pkgs.wireshark-qt;

  home-manager.users.default-user = {
    programs.git = {
      userName = lib.mkForce "Robert Kovacsics";
      userEmail = lib.mkForce "robert.kovacsics@cambridgeconsultants.com";
      extraConfig.http.emptyauth = true;
      lfs.enable = true;
    };
    services.screen-locker.enable = lib.mkForce false;
    xsession.windowManager.i3.config.bars = lib.mkForce [{
      fonts = [ "Latin Modern Roman,Regular 9" ];
    }];
  };

  users.users.build = { isNormalUser = false; group = "build"; shell = "${pkgs.coreutils}/bin/false"; };
  users.groups.build = { };

  networking.hostName = "cc-nixos-a"; # Define your hostname.

  krb5 =
    {
      enable = true;
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
      extraConfig = ''
        [logging]
         default = FILE:/var/log/krb5libs.log
         kdc = FILE:/var/log/krb5kdc.log
         admin_server = FILE:/var/log/kadmind.log
      '';
    };

  services.xserver = {
    inputClassSections = [
      ''
        Identifier "VMMouse"
        MatchDevicePath "/dev/input/event*"
        MatchProduct "ImPS/2 Generic Wheel Mouse"
        Option "EmulateWheel" "1"
        Option "EmulateWheelButton" "2"
        Option "XAxisMapping" "6 7
        Option "YAxisMapping" "4 5"
      ''
    ];
    xkbOptions = "caps:escape";

    displayManager.sessionCommands = ''
      ${pkgs.i3}/bin/i3-msg workspace 1
      ${pkgs.open-vm-tools}/bin/vmware-user-suid-wrapper
      sleep 5s && ~/.fehbg
    '';
  };

  services.udev.packages = [ pkgs.stlink ];

  fileSystems."/shared" =
    {
      device = ".host:/";
      fsType = "fuse./run/current-system/sw/bin/vmhgfs-fuse";
      options = [
        "uid=${toString config.users.users.default-user.uid}"
        "gid=${toString config.users.groups.default-user.gid}"
        "allow_other"
      ];
    };

  nix.maxJobs = 4;
}
