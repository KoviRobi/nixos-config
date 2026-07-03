# vim: set ts=2 sts=2 sw=2 et :
{
  config,
  pkgs,
  lib,
  ...
}@args:
{
  nix = {
    settings = {
      extra-substituters = "https://devenv.cachix.org";
      extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  imports = [
    (import ../modules/linux-console.nix { })
    ../modules/home-manager.nix
    ../modules/nethogs.nix
    ../modules/clipboard.nix
    ../modules/nix-ld-gh326948.nix

    ../packages/network.nix
  ];

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_TIME = "en_DK.UTF-8";
  };

  boot.initrd.systemd.enable = false; # TODDO: Migrate (mainly custom initrd-ssh)

  programs = {
    systemtap.enable = true;

    zsh = {
      enable = true;
      enableCompletion = true;
      enableBashCompletion = true;
    };

    mosh = {
      openFirewall = true;
      enable = true;
    };

    nix-ld-gh326948.systems =
      builtins.mapAttrs
        (
          name:
          { pkgs, ... }@attrs:
          {
            package = pkgs.nix-ld;
            libraries = [
              pkgs.acl
              pkgs.attr
              pkgs.bzip2
              pkgs.cairo
              pkgs.curl
              pkgs.fontconfig
              pkgs.freetype
              pkgs.glib
              pkgs.gtk2
              pkgs.gtk3
              pkgs.libsodium
              pkgs.libssh
              pkgs.libusb1
              pkgs.libxcrypt-legacy
              pkgs.libxml2
              pkgs.ncurses5
              pkgs.openssl
              pkgs.stdenv.cc.cc
              pkgs.systemd
              pkgs.util-linux
              pkgs.libice
              pkgs.libsm
              pkgs.libx11
              pkgs.libxcursor
              pkgs.libxext
              pkgs.libxfixes
              pkgs.libxrandr
              pkgs.libxrender
              pkgs.xz
              pkgs.zlib
              pkgs.zstd
            ];
          }
          // attrs
        )
        {
          ${pkgs.stdenv.hostPlatform.system} = { inherit pkgs; };
        }
      // lib.optionalAttrs (pkgs.stdenv.hostPlatform.system == "x86_64-linux") {
        i686-linux = {
          ldso = "ldso32";
          pkgs = pkgs.pkgsi686Linux;
        };
      };

    xonsh.enable = true;
    bandwhich.enable = true;
    atop = {
      enable = true;
      atopService.enable = true;
      setuidWrapper.enable = true;
    };

    command-not-found.enable = false;
  };

  environment = {
    pathsToLink = [
      "/share/applications"
      "/share/xdg-desktop-portal"
    ];
    homeBinInPath = true;
    systemPackages =
      (import ../packages/base.nix args)
      ++ (import ../packages/better-cli-tools.nix args)
      ++ (import ../packages/lsp.nix args)
      ++ [
        pkgs.busybox # Low priority by default
        pkgs.alsa-ucm-conf
        pkgs.alsa-utils
        pkgs.pw-viz
        (pkgs.makeDesktopItem {
          name = "nixpkgs-manual";
          desktopName = "Nixpkgs Manual";
          genericName = "System Manual";
          comment = "View Nixpkgs documentation in a web browser";
          icon = "nix-snowflake";
          exec = "xdg-open ${pkgs.nixpkgs-manual}/share/doc/nixpkgs/index.html";
          categories = [ "System" ];
        })
        (pkgs.makeDesktopItem {
          name = "nix-manual";
          desktopName = "Nix Manual";
          genericName = "System Manual";
          comment = "View Nix documentation in a web browser";
          icon = "nix-snowflake";
          exec = "xdg-open ${pkgs.nix.doc}/share/doc/nix/manual/index.html";
          categories = [ "System" ];
        })
      ];

    etc."sudo.conf".text = ''
      Path askpass ${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass
    ''; # Using nix-index

    extraOutputsToInstall = [ "terminfo" ];
  };

  documentation = {
    enable = true;
    man.enable = true;
    man.cache.enable = false;
    info.enable = true;
    dev.enable = true;
    nixos.enable = true;
  };

  services = {
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      audio.enable = true;
      pulse.enable = true; # For bluetooth audio
    };

    earlyoom.enable = true;
    clamav = {
      daemon.enable = true;
      updater.enable = true;
    };

    dbus.packages = with pkgs; [ gcr ];
    gnome.gnome-keyring.enable = true;

    udev.extraRules = ''
      SUBSYSTEM=="tty", ATTRS{manufacturer}=="KoviRobi", ATTRS{product}=="Custom steno", SYMLINK="KoviRobi-Steno"
      ACTION=="add", SUBSYSTEM=="usb", ATTR{manufacturer}=="Gabotronics", GROUP="plugdev", MODE="0664", SYMLINK+="XScope%n"
    '';
    udev.packages = with pkgs; [
      openocd
      picotool
      libsigrok
    ];

    tailscale.enable = true;
    resolved.enable = true;
  };

  boot = {
    kernel = {
      sysctl."kernel.sysrq" = 1;
      sysctl."kernel.dmesg_restrict" = 0;
    };
    kernelParams = [ "boot.shell_on_fail" ];
  };

  networking = {
    networkmanager = {
      enable = true;
      plugins = [
        pkgs.networkmanager-openvpn
      ];
    };

    firewall = {
      # To make tailscale work
      checkReversePath = "loose";
      # For syncthing
      allowedTCPPorts = [ 22000 ];
      allowedUDPPorts = [
        21027
        22000
      ];
    };
  };
  systemd = {
    services = {
      NetworkManager-wait-online.serviceConfig.ExecStart = [
        ""
        "${pkgs.networkmanager}/bin/nm-online -q"
      ];

      systemd-udev-settle.enable = false;
      ModemManager.enable = false;
      generate-nix-secret-key = {
        script = ''
          ${pkgs.coreutils}/bin/mkdir -p $(${pkgs.coreutils}/bin/dirname ${config.nix.settings.secret-key-files})

          ${pkgs.nix}/bin/nix-store --generate-binary-cache-key ${config.networking.hostName} ${config.nix.settings.secret-key-files} ${config.nix.settings.secret-key-files}.pub

          chmod 0600 ${config.nix.settings.secret-key-files}
        '';
        wantedBy = [ "nix-daemon.service" ];
        unitConfig = {
          Type = "oneshot";
          ConditionPathExists = "!${config.nix.settings.secret-key-files}";
          Before = [ "nix-daemon.service" ];
        };
      };
    };
    coredump.enable = false;
  };

  security = {
    audit.enable = true;
    auditd.enable = true;
    run0 = {
      enable = true;
      enableSudoAlias = true;
    };
    soteria.enable = true;
    sudo.enable = false;
    pam.services.login.enableGnomeKeyring = true;
    pam.services.sudo.enableGnomeKeyring = true;
  };
  # Ensures soteria re-registers
  systemd.user.services.polkit-soteria.unitConfig.ReloadPropagatedFrom = [ "dbus-broker.service" ];
  systemd.user.services.polkit-soteria.requires = [ "dbus-broker.service" ];
  systemd.user.services.polkit-soteria.after = [ "dbus-broker.service" ];

  users.groups.plugdev = { };

  nix.settings.secret-key-files = "/etc/secrets/nix/secret-key";
}
