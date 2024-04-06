{ pkgs, lib, config, ... }:
{
  imports = [
    ./direnv.nix
    ./git.nix
    ./tmux.nix
    ./x11
    ./shell.nix
    ./solarized.nix
    ./modules/import-nixos-config.nix
    ./helix.nix
  ];

  home.packages = [
    pkgs.fortune
    pkgs.mimi
  ];

  home.file.".terminfo" = { source = "${pkgs.st.terminfo}/share/terminfo"; recursive = true; };

  home.file.".config/mimi/mime.conf".text = ''
    text/html: firefox
    text/: st -e tmux new vim
    application/pdf: zathura
    video/: mpv
    image/: geeqie
    audio/: mpv
    inode/directory: st -e tmux new -c
  '';

  services.gnome-keyring.enable = true;
  home.sessionVariables.SSH_AUTH_SOCK =
    "/run/user/${toString config.nixos.users.users.default-user.uid}/keyring/ssh";
  home.file.".gnupg/gpg-agent.conf".text = ''
    pinentry-program ${pkgs.pinentry-gnome3}/bin/pinentry
  '';

  home.sessionVariables.PYTHONSTARTUP = pkgs.writeText "pythonrc" ''
    try:
        import readline
        import rlcompleter
        readline.parse_and_bind("tab: complete")
        readline.parse_and_bind("set colored-stats off")
    except ImportError:
        print("Module readline not available.")
  '';

  programs.readline.enable = true;
  programs.readline.extraConfig = ''
    set revert-all-at-newline on

    $if python
      set colored-stats off
    $endif
  '';

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

  programs.htop = {
    enable = true;
    settings.color_scheme = 6;
  };
  # htop overwrites symlink
  xdg.configFile."htop/htoprc".force = true;

  programs.home-manager = {
    enable = true;
  };

  programs.newsboat.enable = true;
  programs.newsboat.browser = "${pkgs.mpv}/bin/mpv";
  programs.newsboat.urls = [
    { url = "http://feeds.nightvalepresents.com/welcometonightvalepodcast"; }
  ];
  programs.newsboat.extraConfig = ''
    article-sort-order date
  '';
}
