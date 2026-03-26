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

      def semantic_displayhook(obj, displayhook=sys.displayhook):
          print("\x1b]133;C\x07", end="", flush=True)
          displayhook(obj)
          print("\x1b]133;D;0\x07\x1b]N;aid=python;cl=v\x07", end="", flush=True)

      def semantic_excepthook(exc, val, tb, excepthook=sys.excepthook):
          print("\x1b]133;C\x07", end="", flush=True, file=sys.stderr)
          excepthook(exc, val, tb)
          print("\x1b]133;D;1\x07\x1b]N;aid=python;cl=v\x07", end="", flush=True, file=sys.stderr)

      sys.displayhook = semantic_displayhook
      sys.excepthook = semantic_excepthook

      sys.ps1 = "\1\x1b]133;A;aid=python;cl=v\x07\2>>> \1\x1b]133;I\x07\2"
      sys.ps2 = "\1\x1b]133;P;k=c\x07\2... \1\x1b]133;I\x07\2"
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

        # Emit OSC133 in select terminals (readline doesn't support glob nor "||")
        $if term!=tmux-256color
        $else
        $if term!=foot
        $else
        set show-mode-in-prompt on
        set emacs-mode-string "\1\e]133;N\e\\\2"
        set vi-cmd-mode-string "\1\e]133;N\e\\\2"
        set vi-ins-mode-string "\1\e]133;N\e\\\2"
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
