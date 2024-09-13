{ config, lib, pkgs, ... }:

let
  cfg = config.solarized;
in
{
  options.solarized = with lib; {
    brightness = mkOption {
      type = types.enum [ "dark" "light" ];
      default = "dark";
      description = ''
        Whether to use solarized dark or light by default.
      '';
    };
  };

  config = {
    xresources.extraConfig = ''
      #include "${
        pkgs.fetchFromGitHub {
          owner = "solarized";
          repo = "xresources";
          rev = "025ceddbddf55f2eb4ab40b05889148aab9699fc";
          sha256 = "0lxv37gmh38y9d3l8nbnsm1mskcv10g3i83j0kac0a2qmypv1k9f";
        }}/Xresources.${cfg.brightness}"
    '';

    programs.bat.config.theme = "Solarized (${cfg.brightness})";
    programs.git.delta.options.syntax-theme = "Solarized (${cfg.brightness})";

    # Dark has a better statusline for both light/dark
    programs.tmux.extraConfig = ''
      source-file ${pkgs.tmuxPlugins.tmux-colors-solarized}/share/tmux-plugins/tmuxcolors/tmuxcolors-dark.conf
    '';

    programs.zsh.initExtra =
      let
        github-prefix = "https://raw.githubusercontent.com/seebi/dircolors-solarized/8c361017afb3cadc7cf36d6b94d01b90ae3bc59f";
        dircolors-file = builtins.fetchurl {
          url = "${github-prefix}/dircolors.ansi-universal";
          sha256 = "149j2vgrmmgcjsx20cbdflbpwv4p3lfb0wswjzv2pw0ry5i4rprf";
        };
        dircolors-output = pkgs.runCommand "dircolors-solarized"
          { nativeBuildInputs = [ pkgs.coreutils ]; }
          ''
            < ${dircolors-file} \
            sed 's/^BLK\s\+33;44/BLK 30;44/' \
            | dircolors /dev/stdin > $out
          '';
      in
      ''
        source ${dircolors-output}
      '';

    programs.newsboat.extraConfig = ''
      include "${pkgs.newsboat}/share/doc/newsboat/contrib/colorschemes/solarized-dark"
    '';
  };
}
