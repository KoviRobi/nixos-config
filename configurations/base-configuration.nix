# vim: set ts=2 sts=2 sw=2 et :
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{ nixpkgs.overlays = map (x: import (../overlays + ("/" + x)))
            (with builtins; attrNames (readDir ../overlays));
  nix.nixPath = [ "nixpkgs=/home/rmk35/programming/nix/pkgs/unstable"
                  "nixos-config=/home/rmk35/nixos/configuration.nix"
                  "/home/rmk35/programming/nix/pkgs/unstable" ];

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
    dpi = config.services.xserver.dpi;
    fileSystems = pkgs.lib.mapAttrsToList (k: v: k) config.fileSystems;
  };

  imports = [ (import ../modules/linux-console.nix {})
    "${fetchGit {
      url = https://github.com/rycee/home-manager;
      ref = "release-19.09";
    }}/nixos" ];

  i18n.defaultLocale = "en_US.UTF-8";

  services.localtime.enable = true;

  environment.systemPackages = with pkgs;
  [ wget tmux ispell file netcat socat
    lsof gnupg clamav krb5 pv git
    jq killall # for i3 helpers
    nfs-utils pciutils usbutils
    unzip
    graphviz
    nix-prefetch-git nix-prefetch-github
#   From overlays, see nixpkgs.overlays
    emacs neovim
    (linkFarm "nvim-vi-vim-alias" [
      { name = "bin/vi"; path = "${neovim}/bin/nvim"; }
      { name = "bin/vim"; path = "${neovim}/bin/nvim"; }
    ])
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
  };

  krb5.libdefaults = { default_realm = "DC.CL.CAM.AC.UK"; forwardable = true; };

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

  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPorts = [ ];

  networking.networkmanager = { enable = true; enableStrongSwan = true; };

  systemd.services.systemd-udev-settle.enable = false;
  systemd.services.NetworkManager-wait-online.enable = false;
}
