{
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./direnv.nix
    ./git
    ./tmux.nix
    ./shell.nix
    ./gruvbox.nix
    ./modules/import-nixos-config.nix
    ./helix.nix
    ./neovim
    ./antidot.nix
  ];

  kovirobi.neovim.enable = true;

  home = {
    packages = [
      pkgs.fortune
      pkgs.mimi
    ];

    file = {
      ".terminfo" = {
        source = pkgs.symlinkJoin {
          name = "home-terminfo";
          paths = [
            "${pkgs.st.terminfo}/share/terminfo"
            "${pkgs.ghostty}/share/terminfo"
          ];
        };
        recursive = true;
      };

      ".config/mimi/mime.conf".text = ''
        text/html: librewolf
        text/: ghostty -e tmux new kak
        application/pdf: zathura
        video/: mpv
        image/: display
        audio/: mpv
        inode/directory: st -e tmux new -c
      '';
      ".config/gnupg/gpg-agent.conf".text = ''
        pinentry-program ${pkgs.pinentry-gnome3}/bin/pinentry
      '';
    };
    sessionVariables.SSH_AUTH_SOCK = "/run/user/${toString config.nixos.users.users.default-user.uid}/gcr/ssh";

    sessionVariables.PYTHONSTARTUP = pkgs.writeText "pythonrc" ''
      try:
          import readline
          import rlcompleter
          readline.parse_and_bind("tab: complete")
          readline.parse_and_bind("set colored-stats off")
      except ImportError:
          print("Module readline not available.")

      import os
      import sys
      import collections
      import functools
      import itertools
      import re
      import traceback
      from math import *
      from pathlib import Path

      __old_displayhook = sys.displayhook
      __old_excepthook = sys.excepthook

      def semantic_displayhook(obj):
          print("\x1b]133;C\x1b\\", end="", flush=True)
          __old_displayhook(obj)
          print("\x1b]133;D;0\x1b\\\x1b]133;A;aid=python;cl=v\x1b\\", end="", flush=True)

      def semantic_excepthook(exc, val, tb):
          print("\x1b]133;C\x1b\\", end="", flush=True, file=sys.stderr)
          __old_excepthook(exc, val, tb)
          print("\x1b]133;D;1\x1b\\\n\x1b]133;A;cl=v\x1b\\", end="", flush=True, file=sys.stderr)

      sys.displayhook = semantic_displayhook
      sys.excepthook = semantic_excepthook

    '';
  };

  services = {
    gnome-keyring.enable = true;
    syncthing.enable = true;
  };

  programs = {
    readline = {
      enable = true;
      extraConfig = ''
        set revert-all-at-newline on

        $if bash
        $else
          set colored-stats off
        $endif
      '';
    };

    bat = {
      enable = true;
    };

    ssh = {
      matchBlocks."*" = {
        controlMaster = "auto";
        controlPath = "~/.ssh/master-%r@%h:%p";
        controlPersist = "10m";
        visualHostKey = true;
      };
      includes = [ "config.d/*.conf" ];
    };

    htop = {
      enable = true;
      settings.color_scheme = 6;
    };

    home-manager = {
      enable = true;
    };

    newsboat = {
      enable = true;
      browser = "mpv";
      extraConfig = ''
        article-sort-order date
      '';
    };

    pay-respects.enable = true;
  };
}
