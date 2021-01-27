{ pkgs, lib, ... }:
{
  imports = [
    ./direnv.nix
    ./tmux.nix
    ./x11
    ./zsh.nix
    ./modules/import-fileSystems.nix
  ];

  home.packages = [
    pkgs.fortune
  ];

  services.gnome-keyring.enable = true;
  home.sessionVariables.SSH_AUTH_SOCK = "/run/user/1000/keyring/ssh";

  services.xcape = {
    enable = true;
    mapExpression = { Shift_L = "parenleft"; Shift_R = "parenright"; };
    timeout = 250;
  };

  services.lorri.enable = true;

  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    delta = {
      enable = true;
      options = {
        theme = "Solarized (dark)";
        side-by-side = true;
      };
    };
    userName = "Kovacsics Robert";
    userEmail = "rmk35@cam.ac.uk";
    aliases = {
      lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
    };
    extraConfig = {
      pull.ff = "only";
      help.autoCorrect = 10;
      credential.helper = "libsecret";
    };
  };

  programs.bat = {
    enable = true;
    config.theme = "Solarized (dark)";
  };

  programs.ssh = {
    controlMaster = "auto";
    controlPath = "~/.ssh/master-%r@%h:%p";
    controlPersist = "10m";
    extraConfig = ''
      Host *.cl.cam.ac.uk ely orfina mawddach
        GSSAPIAuthentication yes
        GSSAPIDelegateCredentials yes

      Host nix-hydra
        HostName caelum-vm-127.cl.cam.ac.uk.
        User rmk35
    '';
  };

  programs.htop = { enable = true; colorScheme = 6; };

  programs.home-manager = {
    enable = true;
  };
}
