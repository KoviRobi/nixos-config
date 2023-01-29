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
    home-manager.users.default-user = {
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
          dircolors = "${pkgs.coreutils}/bin/dircolors";
          github-prefix = "https://raw.githubusercontent.com/seebi/dircolors-solarized/fa094443d22aded73c96522b729411d921b1845e";
          dircolors-file = builtins.fetchurl {
            url = "${github-prefix}/dircolors.ansi-${cfg.brightness}";
            sha256 =
              if cfg.brightness == "dark"
              then "1m1ba6xnm7hhzmlhmrcg99cp4w7pwfg8kqr6lwirjd8yjbaj0a0n"
              else "0a7411dni1ih54z252jcpsxiyx84aabidjfi8lz28s0878acglhw";
          };
          dircolors-output = pkgs.runCommand ''dircolors-solarized'' { }
            "${dircolors} ${dircolors-file} > $out";
        in
        ''
          source ${dircolors-output}
        '';

      programs.newsboat.extraConfig = ''
        include "${pkgs.newsboat}/share/doc/newsboat/contrib/colorschemes/solarized-dark"
      '';
    };

    nixpkgs.overlays = [
      (self: super: {
        st = super.st.override {
          patches = super.st.patches ++ [
            ../patches/st-0.8.5-solarized-swap.patch
          ] ++ lib.optional (cfg.brightness == "light")
            ../patches/st-0.8.5-solarized-swap-default-light.patch
          ;
        };
      })
    ];
  };
}
