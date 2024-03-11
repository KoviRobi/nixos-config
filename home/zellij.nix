{ pkgs, config, lib, ... }:
{
  programs.zellij = {
    enable = true;
    settings = {
      pane_frames = false;

      session_serialization = false;

      theme = "solarized_light";

      themes.solarized_dark.fg = "#FDF6E3";
      themes.solarized_dark.bg = "#002B36";
      themes.solarized_dark.black = "#EEE8D5";
      themes.solarized_dark.white = "#073642";
      themes.solarized_dark.red = "#DC322F";
      themes.solarized_dark.green = "#859900";
      themes.solarized_dark.yellow = "#B58900";
      themes.solarized_dark.blue = "#268BD2";
      themes.solarized_dark.magenta = "#D33682";
      themes.solarized_dark.cyan = "#2AA198";
      themes.solarized_dark.orange = "#CB4B16";

      themes.solarized_light.fg = "#657B83";
      themes.solarized_light.bg = "#FDF6E3";
      themes.solarized_light.black = "#EEE8D5";
      themes.solarized_light.white = "#073642";
      themes.solarized_light.red = "#DC322F";
      themes.solarized_light.green = "#859900";
      themes.solarized_light.yellow = "#B58900";
      themes.solarized_light.blue = "#268BD2";
      themes.solarized_light.magenta = "#D33682";
      themes.solarized_light.cyan = "#2AA198";
      themes.solarized_light.orange = "#CB4B16";
    };
  };
}
