# vim: set ts=2 sts=2 sw=2 et :
{ config, pkgs, lib, ... }:

let HOME = config.users.users.default-user.home;
in
{ nixpkgs.overlays = map (x: import (../overlays + ("/" + x)))
            (with builtins; attrNames (readDir ../overlays));
  nix.nixPath = [ "nixpkgs=${HOME}/programming/nix/pkgs/unstable"
                  "nixos-config=${HOME}/nixos/configuration.nix"
                  "home-manager=${HOME}/programming/nix/home-manager"
                  "${HOME}/programming/nix/pkgs/unstable" ];

  imports = [
    (import ../modules/linux-console.nix {})
    ../modules/home-manager.nix
  ];

  i18n.defaultLocale = "en_US.UTF-8";

  services.localtime.enable = true;

  environment.homeBinInPath = true;
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
  boot.kernelParams = [ "boot.shell_on_fail" ];

  services =
  { earlyoom.enable = true;
    clamav = { daemon.enable = true; updater.enable = true; };
  };

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
  systemd.services.ModemManager.enable = false;
}
