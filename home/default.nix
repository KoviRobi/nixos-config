{
  imports = [
    ./base.nix
    ./x11
  ];

  # mandoc seems to be much faster
  programs.man.man-db.enable = false;
  programs.man.mandoc.enable = false;
}
