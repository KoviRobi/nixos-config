# vim: set ts=2 sts=2 sw=2 et :
{ config, pkgs, lib, ... }:

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
  services.xserver.xrandrHeads = [
    { output = "DP-1"; }
    { output = "HDMI-2"; primary = true; monitorConfig = ''Option "BROADCAST_RGB" "1"''; }
  ];
  home-manager.users.default-user = {
    xresources.extraConfig = ''
            #include "${
      pkgs.fetchFromGitHub
              {
                owner = "solarized";
                repo = "xresources";
                rev = "025ceddbddf55f2eb4ab40b05889148aab9699fc";
                sha256 = "0lxv37gmh38y9d3l8nbnsm1mskcv10g3i83j0kac0a2qmypv1k9f";
              }
            }/Xresources.light"
    '';
    xsession.initExtra = ''
      xrandr --output DP-1 --set 'Broadcast RGB' Full
    '';
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.xserver.videoDrivers = [ "i915" "modesetting" "nouveau" "fbdev" ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.supportedFilesystems = [ "cifs" ];

  networking.hostName = "rmk-nixos-a"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  home-manager.users.default-user = {
    programs.git = {
      userName = lib.mkForce "Robert Kovacsics";
      userEmail = lib.mkForce "robert.kovacsics@cambridgeconsultants.com";
      extraConfig.http.emptyauth = true;
      lfs.enable = true;
    };
  };

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
}
