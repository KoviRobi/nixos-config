{ pkgs, lib, config, ... }:
{
  imports = [
    ./direnv.nix
    ./tmux.nix
    ./x11
    ./zsh.nix
    ./modules/import-nixos-config.nix
  ];

  home.packages = [
    pkgs.fortune
  ];

  services.gnome-keyring.enable = true;
  home.sessionVariables.SSH_AUTH_SOCK =
    "/run/user/${toString config.nixos.users.users.default-user.uid}/keyring/ssh";
  home.file.".gnupg/gpg-agent.conf".text = ''
    pinentry-program ${pkgs.pinentry.gnome3}/bin/pinentry
  '';

  services.xcape = {
    enable = true;
    mapExpression = { Shift_L = "parenleft"; Shift_R = "parenright"; };
    timeout = 250;
  };

  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    delta = {
      enable = true;
      options = {
        side-by-side = true;
      };
    };
    userName = "Kovacsics Robert";
    userEmail = lib.mkDefault "kovirobi@gmail.com";
    aliases = {
      lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      pcc = "push -o merge_request.create -o merge_request.remove_source_branch -o merge_request.assign='robert.kovacsics' -o merge_request.target=master";
      prich = "push -o merge_request.create -o merge_request.remove_source_branch -o merge_request.assign='robert.kovacsics' -o merge_request.target=richmond";
      pgl = "push -o merge_request.create -o merge_request.remove_source_branch -o merge_request.assign='rmk' -o merge_request.target=master";

    };
    extraConfig = {
      pull.ff = "only";
      help.autoCorrect = 10;
      credential.helper = "libsecret";
      commit.verbose = true;
      merge.tool = "nvimdiff";
      init.defaultBranch = "main";
    };
  };

  programs.bat = {
    enable = true;
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

  programs.htop = { enable = true; settings.color_scheme = 6; };

  programs.home-manager = {
    enable = true;
  };

  programs.nix-index.enable = true;

  programs.newsboat.enable = true;
  programs.newsboat.browser = "${pkgs.mpv}/bin/mpv";
  programs.newsboat.urls = [
    { url = "http://feeds.nightvalepresents.com/welcometonightvalepodcast"; }
  ];
  programs.newsboat.extraConfig = ''
    article-sort-order date
  '';
}
