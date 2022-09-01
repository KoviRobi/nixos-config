{ pkgs, config, lib, ... }:
{
  environment = {

    systemPackages = with pkgs; [
      starship
    ];

    shellInit = ''
      export STARSHIP_CONFIG=${
        (pkgs.formats.toml {}).generate "starship.toml" {
          format = "$all$line_break$character";
          docker_context.symbol = "  ";
          erlang.symbol = "  ";
          helm.symbol = "[ﴱ ](fg:blue) ";
          kubernetes.symbol = "[ﴱ ](fg:white bg:blue) ";
          memory_usage.symbol = "🐏 ";
          nix_shell.symbol = "";
          nix_shell.pure_msg = "[ ]()";
          nix_shell.impure_msg = "[ ](blue)";
          pulumi.symbol = "  ";
          aws.disabled = true;
          directory.truncation_symbol = "…/";
          shell.disabled = false;
          status.disabled = false;
          status.symbol = "✖ ";
          time.disabled = false;
        }
      }
    '';
  };

  programs.bash.promptInit = ''
    if [[ $TERM != "dumb" && (-z $INSIDE_EMACS || $INSIDE_EMACS == "vterm") ]]; then
      eval "$(${pkgs.starship}/bin/starship init bash)"
    fi
  '';

  programs.zsh.promptInit = ''
    if [[ $TERM != "dumb" && (-z $INSIDE_EMACS || $INSIDE_EMACS == "vterm") ]]; then
      eval "$(${pkgs.starship}/bin/starship init zsh)"
    fi
  '';

  programs.xonsh.config = ''
    execx($(starship init xonsh))
  '';
}
