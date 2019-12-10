# vim: set ts=2 sts=2 sw=2 et :
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{ nixpkgs.overlays = map (x: import (../overlays + ("/" + x)))
            (with builtins; attrNames (readDir ../overlays));

  users.users.rmk35 =
  { isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "users" "wheel" "cdrom" "dialout" "networkmanager" ];
    uid = 3749;
    group = "rmk35";
  };
  users.groups.rmk35 = { gid = 3749; members = [ "rmk35" ]; };

  home-manager.useUserPackages = true;
  home-manager.users.rmk35 = { ... }: {
    imports = [ ../home ];
    nixpkgs.overlays = config.nixpkgs.overlays;
  };

  imports = [ (import ../modules/linux-console.nix {})
    "${fetchTarball {
      url = https://github.com/rycee/home-manager/archive/release-19.09.tar.gz;
      sha256 = "1pnswdidlh8kapqjqsl5jyr09mfwv14h9p1krqj743pfxkbp6i0y";
    }}/nixos" ];

  i18n.defaultLocale = "en_US.UTF-8";

  time.timeZone = "Europe/London";

  environment.systemPackages = with pkgs;
  [ wget tmux ispell file netcat socat
    lsof gnupg clamav krb5
    jq killall # for i3 helpers
    ] ++ (with xorg; [ xkbprint xkbutils ]) ++ [
    xclip
    hicolor-icon-theme gnome3.adwaita-icon-theme
    libnotify
    chromium mpv ffmpeg compton zathura
    nfs-utils pciutils
    unzip
    graphviz
    nix-prefetch-git nix-prefetch-github
#   From overlays, see nixpkgs.overlays
    emacs neovim
  ];

  fonts.fonts = with pkgs; [ noto-fonts dejavu_fonts lmodern ];

  documentation.dev.enable = true;

  #sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.bluetooth =
  { enable = true;
    package = pkgs.bluezFull;
  };

  boot.kernel.sysctl."kernel.sysrq" = 1;

  services =
  { earlyoom.enable = true;

    clamav = { daemon.enable = true; updater.enable = true; };

    xserver =
    { enable = true; layout = "us";
      displayManager.lightdm = {
        enable = true;
        autoLogin = { enable = true; user = "rmk35"; };
        greeters.gtk.cursorTheme.package = pkgs.gnome3.adwaita-icon-theme;
        greeters.gtk.cursorTheme.name = "Adwaita";
      };
      windowManager.i3.enable = true;
      windowManager.default = "i3";
      desktopManager.default = "none";
      exportConfiguration = true;
      inputClassSections = [ ''
        Identifier "Kensington SlimBlade"
        MatchProduct "Kensington Kensington Slimblade Trackball"
        Driver "evdev"
        Option "ButtonMapping" "1 10 3 8 9 6 7 2 4 5 11 12"
        Option "EmulateWheel" "1"
        Option "EmulateWheelButton" "2"
        Option "XAxisMapping" "6 7
        Option "YAxisMapping" "9 10"
        Option "EmulateWheelInertia" "5"
        Option "Device Accel Profile" "-1"
      ''
      ''
        Identifier "ELECOM HUGE TrackBall"
        MatchProduct "ELECOM TrackBall Mouse HUGE TrackBall"
        Driver "evdev"
        Option "ButtonMapping" "10 11 3 4 5 6 7 2 1 9 8 12"
        Option "EmulateWheel" "1"
        Option "EmulateWheelButton" "1"
        Option "EmulateWheelInertia" "5"
        Option "Device Accel Profile" "-1"
      ''
      ''
        Identifier "Clearly Superior Trackball"
        MatchProduct "Clearly Superior Technologies. CST Laser Trackball"
        Driver "evdev"
        Option "EmulateWheel" "1"
        Option "Device Accel Profile" "-1"
        Option "XAxisMapping" "6 7
        Option "YAxisMapping" "9 10"
        Option "EmulateWheelInertia" "5"
      ''
      ''
        Identifier "Logitech M570"
        MatchProduct "Logitech M570"
        Driver "evdev"
        Option "ButtonMapping" "1 9 3 4 5 6 7 2 8"
        Option "EmulateWheel" "1"
        Option "EmulateWheelButton" "8"
        Option "XAxisMapping" "6 7"
        Option "YAxisMapping" "4 5"
      '' ];
    };
  };

  krb5.libdefaults = { default_realm = "DC.CL.CAM.AC.UK"; };

  programs =
  { gnupg.agent = { enable = true; enableSSHSupport = true; };
    zsh =
    { enable = true;
      autosuggestions = { enable = true; highlightStyle = "fg=white"; };
      ohMyZsh.enable = true;
      syntaxHighlighting.enable = true;
    };
    thefuck = { enable = true; alias = "fck"; };
  };

  gtk.iconCache.enable = false; # Normally slow, and I don't use icons anyway

  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPorts = [ ];

  networking.networkmanager = { enable = true; enableStrongSwan = true; };
}
