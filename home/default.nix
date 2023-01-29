{ pkgs, lib, config, ... }:
{
  imports = [
    ./direnv.nix
    ./git.nix
    ./tmux.nix
    ./x11
    ./shell.nix
    ./modules/import-nixos-config.nix
  ];

  home.packages = [
    pkgs.fortune
  ];

  services.gnome-keyring.enable = true;
  home.sessionVariables.SSH_AUTH_SOCK =
    "/run/user/${toString config.nixos.users.users.default-user.uid}/keyring/ssh";
  home.file.".gnupg/gpg-agent.conf".text = ''
    pinentry-program ${pkgs.pinentry-gnome}/bin/pinentry
  '';

  services.xcape = {
    enable = true;
    mapExpression = { Shift_L = "parenleft"; Shift_R = "parenright"; };
    timeout = 250;
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

  programs.zoxide.enable = true;

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
