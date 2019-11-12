# vim: set ts=2 sts=2 sw=2 et :
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }@args:

{ nixpkgs.overlays = map import [ ../overlays/emacs.nix ../overlays/vim.nix ];

  imports = [ "${fetchTarball {
    url = https://github.com/rycee/home-manager/archive/release-19.09.tar.gz;
    sha256 = "16ibf367ay6dkwv6grrkpx8nf0nz3jlr3xxpjv4zjj0v3imwlq6b";
  }}/nixos" ];

  i18n =
  { consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "Europe/London";

  environment.systemPackages = with pkgs;
  [ wget tmux ispell git htop file direnv netcat socat stow
    lsof gnupg clamav krb5
    jq killall # for i3 helpers
    ] ++ (with xorg; [ xkbprint xkbutils ]) ++ [
    xcape xclip clipster
    hicolor-icon-theme
    dunst libnotify
    chromium mpv ffmpeg compton zathura
    nfs-utils pciutils
    unzip
#   From overlays, see nixpkgs.overlays
    myEmacs myNeovim
    graphviz
    nix-prefetch-git nix-prefetch-github
    networkmanagerapplet
  ];

  fonts.fonts = with pkgs; [ noto-fonts ];

  documentation.dev.enable = true;

  #sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.bluetooth =
  { enable = true;
    package = pkgs.bluezFull;
  };

  services =
  { earlyoom.enable = true;

    clamav = { daemon.enable = true; updater.enable = true; };

    xserver =
    { enable = true; layout = "us";
      displayManager.lightdm.enable = true;
      displayManager.lightdm.autoLogin = { enable = true; user = "rmk35"; };
      windowManager.i3.enable = true;
      windowManager.default = "i3";
      desktopManager.default = "none";
      exportConfiguration = true;
      inputClassSections = [ ''
        Identifier "Kensington SlimBlade"
        MatchProduct "Kensington Kensington Slimblade Trackball"
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
        Option "ButtonMapping" "10 11 3 4 5 6 7 2 1 9 8 12"
        Option "EmulateWheel" "1"
        Option "EmulateWheelButton" "1"
        Option "EmulateWheelInertia" "5"
        Option "Device Accel Profile" "-1"
      ''
      ''
        Identifier "Clearly Superior Trackball"
        MatchProduct "Clearly Superior Technologies. CST Laser Trackball"
        Option "EmulateWheel" "1"
        Option "Device Accel Profile" "-1"
        Option "XAxisMapping" "6 7
        Option "YAxisMapping" "9 10"
        Option "EmulateWheelInertia" "5"
      ''
      ''
        Identifier "Logitech M570"
        MatchProduct "Logitech M570"
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
    sway =
    { enable = true;
      extraPackages = with pkgs; [ xwayland i3status i3status-rust termite rofi light ];
      extraSessionCommands = ''
        export SDL_VIDEODRIVER=wayland
        # needs qt5.qtwayland in systemPackages
        export QT_QPA_PLATFORM=wayland
        export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
        # Fix for some Java AWT applications (e.g. Android Studio),
        # use this if they aren't displayed properly:
        export _JAVA_AWT_WM_NONREPARENTING=1
      '';
    };
    zsh =
    { enable = true;
      autosuggestions = { enable = true; highlightStyle = "fg=white"; };
      ohMyZsh.enable = true;
      syntaxHighlighting.enable = true;
    };
    thefuck = { enable = true; alias = "fck"; };
  };

  gtk.iconCache.enable = false; # Normally slow, and I don't use icons anyway

  users.users.rmk35 =
  { isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "users" "wheel" "cdrom" "dialout" ];
    uid = 3749;
    group = "rmk35";
  };
  users.groups.rmk35 = { gid = 3749; members = [ "rmk35" ]; };

  home-manager.useUserPackages = true;
  home-manager.users.rmk35 = import ../home args;

  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPorts = [ ];

  networking.networkmanager = { enable = true; enableStrongSwan = true; };
}
