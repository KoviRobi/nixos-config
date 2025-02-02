# vim: set ts=2 sts=2 sw=2 et :
{
  config,
  pkgs,
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
    };
  };

  imports = [
    (import ../modules/linux-console.nix { })
    ../modules/home-manager.nix
    ../modules/nethogs.nix
    ../modules/clipboard.nix

    ../packages/network.nix
  ];

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_TIME = "en_DK.UTF-8";
  };

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

    nix-ld = {
      enable = true;
      package = pkgs.nix-ld-rs;
      libraries = [
        pkgs.gtk3
        pkgs.gtk2
        pkgs.cairo
        pkgs.glib
        pkgs.ncurses5
        pkgs.libxcrypt-legacy
      ];
    };

    nix-ld-32 = {
      enable = true;
      package = pkgs.pkgsi686Linux.nix-ld-rs;
      libraries = [
        pkgs.pkgsi686Linux.gtk3
        pkgs.pkgsi686Linux.gtk2
        pkgs.pkgsi686Linux.cairo
        pkgs.pkgsi686Linux.glib
        pkgs.pkgsi686Linux.ncurses5
        pkgs.pkgsi686Linux.libxcrypt-legacy
      ];
    };

    xonsh.enable = true;
    bandwhich.enable = true;
    atop = {
      enable = true;
      atopService.enable = true;
      netatop.enable = true;
      setuidWrapper.enable = true;
    };

    command-not-found.enable = false;
  };

  environment = {
    homeBinInPath = true;
    systemPackages =
      (import ../packages/base.nix args) ++ (import ../packages/better-cli-tools.nix args);
    etc."sudo.conf".text = ''
      Path askpass ${pkgs.x11_ssh_askpass}/libexec/x11-ssh-askpass
    ''; # Using nix-index

    extraOutputsToInstall = [ "terminfo" ];
  };

  documentation = {
    enable = true;
    man.enable = true;
    man.generateCaches = true;
    info.enable = true;
    dev.enable = true;
    nixos.enable = true;
  };

  services = {
    pipewire.enable = true;

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
  hardware.bluetooth.enable = true;

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
      enableStrongSwan = true;
    };

    # To make tailscale work
    firewall.checkReversePath = "loose";
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
    coredump.enable = true;
  };

  security = {
    audit.enable = true;
    auditd.enable = true;
    pam.services.login.enableGnomeKeyring = true;
    pam.services.sudo.enableGnomeKeyring = true;
  };

  users.groups.plugdev = { };

  nix.settings.secret-key-files = "/etc/secrets/nix/secret-key";
}
