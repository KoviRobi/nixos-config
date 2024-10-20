{ pkgs, config, lib, ... }:
{

  home.packages = with pkgs; [ starship ];

  programs.starship.enable = true;
  # Handled manually to replace `= {` with `= {||`
  programs.starship.enableNushellIntegration = false;
  programs.starship.settings = {
    format = "$all$line_break$character";
    aws.disabled = true;
    directory.truncation_symbol = "…/";
    shell.disabled = false;
    status.disabled = false;
    time.disabled = false;
    shlvl.disabled = false;
    shlvl.symbol = "↕️";
    shlvl.threshold = lib.mkDefault 3;
    git_commit.only_detached = false;
    git_commit.tag_disabled = false;
  };
}
