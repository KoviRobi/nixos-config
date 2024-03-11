{ pkgs, config, lib, ... }:
{
  programs.zellij = {
    enable = true;
    settings = {
      pane_frames = false;

      theme = "solarized-light";

      themes.solarized-dark.fg = "#FDF6E3";
      themes.solarized-dark.bg = "#002B36";
      themes.solarized-dark.black = "#EEE8D5";
      themes.solarized-dark.white = "#073642";
      themes.solarized-dark.red = "#DC322F";
      themes.solarized-dark.green = "#859900";
      themes.solarized-dark.yellow = "#B58900";
      themes.solarized-dark.blue = "#268BD2";
      themes.solarized-dark.magenta = "#D33682";
      themes.solarized-dark.cyan = "#2AA198";
      themes.solarized-dark.orange = "#CB4B16";

      themes.solarized-light.fg = "#657B83";
      themes.solarized-light.bg = "#FDF6E3";
      themes.solarized-light.black = "#EEE8D5";
      themes.solarized-light.white = "#073642";
      themes.solarized-light.red = "#DC322F";
      themes.solarized-light.green = "#859900";
      themes.solarized-light.yellow = "#B58900";
      themes.solarized-light.blue = "#268BD2";
      themes.solarized-light.magenta = "#D33682";
      themes.solarized-light.cyan = "#2AA198";
      themes.solarized-light.orange = "#CB4B16";
    };
  };
}
