{ pkgs, lib, ... }:
{
  imports = [ ./direnv.nix ./tmux.nix ./x11 ./zsh.nix ];

  home.packages = [
    pkgs.htop
    pkgs.fortune
  ];

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };

  services.xcape = {
    enable = true;
    mapExpression = { Shift_L = "parenleft"; Shift_R = "parenright"; };
    timeout = 250;
  };

  programs.git = {
    enable = true;
    userName = "Kovacsics Robert";
    userEmail = "rmk35@cam.ac.uk";
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

  programs.home-manager = {
    enable = true;
  };
}
