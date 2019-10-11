# vim: set ts=2 sts=2 sw=2 et :
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{ imports = [ ./programming.nix ];

  nixpkgs.overlays = map import [ ./overlays/emacs.nix ./overlays/vim.nix ];

  i18n =
  { consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "Europe/London";

  environment.systemPackages = with pkgs;
  [ wget tmux ispell git htop file direnv netcat socat stow
    gnupg clamav krb5
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
  };

  gtk.iconCache.enable = false; # Normally slow, and I don't use icons anyway

  users.users.rmk35 =
  { isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "rmk35" "wheel" "cdrom" "dialout" ]; # Enable ‘sudo’ for the user.
    uid = 3749;
  };
  users.groups.rmk35 = { gid = 3749; members = [ "rmk35" ]; };

  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPorts = [ ];
}
