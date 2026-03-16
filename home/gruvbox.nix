{
  lib,
  pkgs,
  ...
}:

let
  colours = rec {
    dark0_hard = "#1D2021";
    dark0 = "#282828";
    dark0_soft = "#32302F";
    dark1 = "#3C3836";
    dark2 = "#504945";
    dark3 = "#665C54";
    dark4 = "#7C6F64";

    gray = "#928374";

    light0_hard = "#F9F5D7";
    light0 = "#FBF1C7";
    light0_soft = "#F2E5BC";
    light1 = "#EBDBB2";
    light2 = "#D5C4A1";
    light3 = "#BDAE93";
    light4 = "#A89984";

    bright_red = "#FB4934";
    bright_green = "#B8BB26";
    bright_yellow = "#FABD2F";
    bright_blue = "#83A598";
    bright_purple = "#D3869B";
    bright_aqua = "#8EC07C";
    bright_orange = "#FE8019";

    neutral_red = "#CC241D";
    neutral_green = "#98971A";
    neutral_yellow = "#D79921";
    neutral_blue = "#458588";
    neutral_purple = "#B16286";
    neutral_aqua = "#689D6A";
    neutral_orange = "#D65D0E";

    faded_red = "#9D0006";
    faded_green = "#79740E";
    faded_yellow = "#B57614";
    faded_blue = "#076678";
    faded_purple = "#8F3F71";
    faded_aqua = "#427B58";
    faded_orange = "#AF3A03";

    red = neutral_red;
    green = neutral_green;
    yellow = neutral_yellow;
    blue = neutral_blue;
    purple = neutral_purple;
    aqua = neutral_aqua;
    orange = neutral_orange;

  };
in
{
  options.gruvbox = with lib; {
    colours = {
      general = mkOption {
        readOnly = true;
        type = types.attrsOf types.str;
        description = ''
          Gruvbox brightness independent colours
        '';
        default = colours;
      };
      light = mkOption {
        readOnly = true;
        type = types.attrsOf types.str;
        description = ''
          Gruvbox light-mode bg/fg colours
        '';
        default = with colours; {
          bg0_hard = light0_hard;
          bg0 = light0;
          bg0_soft = light0_soft;
          bg1 = light1;
          bg2 = light2;
          bg3 = light3;
          bg4 = light4;

          fg0_hard = dark0_hard;
          fg0 = dark0;
          fg0_soft = dark0_soft;
          fg1 = dark1;
          fg2 = dark2;
          fg3 = dark3;
          fg4 = dark4;
        };
      };
      dark = mkOption {
        readOnly = true;
        type = types.attrsOf types.str;
        description = ''
          Gruvbox light-mode bg/fg colours
        '';
        default = with colours; {
          bg0_hard = dark0_hard;
          bg0 = dark0;
          bg0_soft = dark0_soft;
          bg1 = dark1;
          bg2 = dark2;
          bg3 = dark3;
          bg4 = dark4;

          fg0_hard = light0_hard;
          fg0 = light0;
          fg0_soft = light0_soft;
          fg1 = light1;
          fg2 = light2;
          fg3 = light3;
          fg4 = light4;
        };
      };
    };
    brightness = mkOption {
      type = types.enum [
        "dark"
        "light"
      ];
      default = "dark";
      description = ''
        Whether to use gruvbox dark or light by default.
      '';
    };
  };

  config = {
    xresources.properties = builtins.listToAttrs (
      map (n: {
        name = "*.${n}";
        value = colours.${n};
      }) (builtins.attrNames colours)
    );

    home.pointerCursor = {
      package = pkgs.capitaine-cursors-themed;
      name = "Capitaine Cursors (Gruvbox)";
      gtk.enable = true;
      x11.enable = true;
    };

    programs = {
      bat.config.theme-light = "gruvbox-light";
      bat.config.theme-dark = "gruvbox-dark";
      delta.options.syntax-theme = "gruvbox-dark"; # Sets both dark and light

      tmux.extraConfig = ''
        run-shell "tmux source-file ${pkgs.tmux-gruvbox-v1}/share/tmux-plugins/gruvbox/tmux-gruvbox-$(cat ~/.local/state/brightness || echo light).conf"
      '';

      zsh.initContent =
        let
          github-prefix = "https://raw.githubusercontent.com/seebi/dircolors-solarized/8c361017afb3cadc7cf36d6b94d01b90ae3bc59f";
          dircolors-file = builtins.fetchurl {
            url = "${github-prefix}/dircolors.ansi-universal";
            sha256 = "149j2vgrmmgcjsx20cbdflbpwv4p3lfb0wswjzv2pw0ry5i4rprf";
          };
          dircolors-output =
            pkgs.runCommand "dircolors-solarized" { nativeBuildInputs = [ pkgs.coreutils ]; }
              ''
                < ${dircolors-file} \
                sed 's/^BLK\s\+33;44/BLK 30;44/' \
                | dircolors /dev/stdin > $out
              '';
        in
        ''
          source ${dircolors-output}
        '';

      newsboat.extraConfig = ''
        include "${pkgs.newsboat}/share/doc/newsboat/contrib/colorschemes/solarized-dark"
      '';
    };
  };
}
