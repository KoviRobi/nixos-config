{
  lib,
  pkgs,
  ...
}:

let
  rgb =
    r: g: b:
    "#${lib.toHexString r}, ${lib.toHexString g}, ${lib.toHexString b}";
  rgba =
    r: g: b: a:
    "#${lib.toHexString r}${lib.toHexString g}${lib.toHexString b}${lib.toHexString a}";
  tup3 =
    r: g: b:
    "${toString r}, ${toString g}, ${toString b}";
  tup4 =
    r: g: b: a:
    "${toString r}, ${toString g}, ${toString b}, ${toString (builtins.div a 256.0)}";

  colours = rec {
    dark0_hard = f: f 29 32 33;
    dark0 = f: f 40 40 40;
    dark0_soft = f: f 50 48 47;
    dark1 = f: f 60 56 54;
    dark2 = f: f 80 73 69;
    dark3 = f: f 102 92 84;
    dark4 = f: f 124 111 100;

    gray = f: f 146 131 116;

    light0_hard = f: f 249 245 215;
    light0 = f: f 251 241 199;
    light0_soft = f: f 242 229 188;
    light1 = f: f 235 219 178;
    light2 = f: f 213 196 161;
    light3 = f: f 189 174 147;
    light4 = f: f 168 153 132;

    bright_red = f: f 251 73 52;
    bright_green = f: f 184 187 38;
    bright_yellow = f: f 250 189 47;
    bright_blue = f: f 131 165 152;
    bright_purple = f: f 211 134 155;
    bright_aqua = f: f 142 192 124;
    bright_orange = f: f 254 128 25;

    neutral_red = f: f 204 36 29;
    neutral_green = f: f 152 151 26;
    neutral_yellow = f: f 215 153 33;
    neutral_blue = f: f 69 133 136;
    neutral_purple = f: f 177 98 134;
    neutral_aqua = f: f 104 157 106;
    neutral_orange = f: f 214 93 14;

    faded_red = f: f 157 0 6;
    faded_green = f: f 121 116 14;
    faded_yellow = f: f 181 118 20;
    faded_blue = f: f 7 102 120;
    faded_purple = f: f 143 63 113;
    faded_aqua = f: f 66 123 88;
    faded_orange = f: f 175 58 3;

    red = neutral_red;
    green = neutral_green;
    yellow = neutral_yellow;
    blue = neutral_blue;
    purple = neutral_purple;
    aqua = neutral_aqua;
    orange = neutral_orange;
  };

  brightnesses = with colours; {
    general = colours;

    light = {
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

    dark = {
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
in
{
  options.gruvbox = with lib; {
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
    xdg.configFile =
      let
        genColourFile =
          mkName: mkValue:
          lib.genAttrs' [ "light" "dark" "general" ] (type: {
            name = mkName type;
            value.text =
              let
                colours = brightnesses.${type};
              in
              lib.concatMapStrings (name: mkValue name colours.${name} + "\n") (builtins.attrNames colours);
          });
      in
      genColourFile (n: "sway/${n}.conf") (n: col: "set \$${n} ${col rgba 229}")
      // genColourFile (n: "waybar/${n}.css") (n: col: "@define-color ${n} rgba(${col tup4 229});");

    xresources.properties = builtins.listToAttrs (
      map (n: {
        name = "*.${n}";
        value = colours.${n} rgb;
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
