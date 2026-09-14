# vim: set ts=2 sts=2 sw=2 et :
{
  pkgs,
  lib,
  ...
}:

{
  fonts.enableDefaultPackages = true;
  fonts.packages = with pkgs; [
    noto-fonts
    dejavu_fonts
    liberation_ttf
    lmodern
    nerd-fonts.dejavu-sans-mono
    nerd-fonts.caskaydia-cove
    inconsolata
  ];

  imports = [ ../packages/desktop-environment.nix ];

  programs = {
    sway.enable = true;
    foot = {
      enable = true;
      theme = "gruvbox";
      settings = {
        main = {
          font = "CaskaydiaCove Nerd Font Mono:size=10";
        };
      };
    };
  };

  xdg.portal = {
    enable = true;
    wlr = {
      enable = true;
      settings = {
        screencast = {
          max_fps = 30;
          exec_before = "${lib.getExe' pkgs.dunst "dunstctl"} set-paused true";
          exec_after = "${lib.getExe' pkgs.dunst "dunstctl"} set-paused false";
          chooser_type = "simple";
          chooser_cmd = "${lib.getExe pkgs.slurp} -f 'Monitor: %o' -or";
        };
      };
    };
  };

  services = {
    accounts-daemon.enable = true; # For regreet
    udisks2.enable = true;
    greetd.enable = true;
    displayManager.regreet = {
      enable = true;
      theme = {
        package = pkgs.gruvbox-dark-gtk;
        name = "gruvbox-dark";
      };
      iconTheme = {
        package = pkgs.gruvbox-dark-icons-gtk;
        name = "oomox-gruvbox-dark";
      };
      cursorTheme = {
        package = pkgs.capitaine-cursors-themed;
        name = "Capitaine Cursors (Gruvbox)";
      };
      settings = {
        GTK = {
          application_prefer_dark_theme = true;
        };
      };
      cageArgs = [
        "-s"
        "-m"
        "last"
      ];
    };
  };
}
