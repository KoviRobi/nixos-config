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
    ./x11
    ./shell.nix
    ./solarized.nix
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
            "${pkgs.ghostty}/share/terminfo"
          ];
        };
        recursive = true;
      };

      ".config/mimi/mime.conf".text = ''
        text/html: firefox
        text/: st -e tmux new vim
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
      controlMaster = "auto";
      controlPath = "~/.ssh/master-%r@%h:%p";
      controlPersist = "10m";
      extraConfig = ''
        Host *
          ControlMaster auto
          ControlPath ~/.ssh/master-%r@%h:%p
          ControlPersist 10m
          VisualHostKey yes

        Include config.d/*.conf
      '';
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
