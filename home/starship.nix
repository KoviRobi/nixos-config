{ pkgs, config, lib, ... }:
{

  home.packages = with pkgs; [ starship ];

  programs.starship.enable = true;
  programs.starship.settings = {
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
    shlvl.disabled = false;
    shlvl.symbol = "↕️";
    shlvl.threshold = lib.mkDefault 3;
  };
}
