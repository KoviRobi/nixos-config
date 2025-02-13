{
  pkgs,
  lib,
  ...
}:
{

  home.packages = with pkgs; [ starship ];

  programs = {
    starship = {
      enable = true;
      # Handled manually to replace `= {` with `= {||`
      enableNushellIntegration = false;
      settings = {
        format = "$all$line_break$character";
        aws.disabled = true;
        directory.truncation_symbol = "…/";
        hostname = {
          ssh_only = false;
          ssh_symbol = builtins.fromJSON ''"\b\b\b🖧  "'';
          format = "[🖳  $ssh_symbol$hostname]($style) in ";
        };
        username.show_always = true;
        shell.disabled = false;
        status.disabled = false;
        time.disabled = false;
        shlvl = {
          disabled = false;
          symbol = "↕";
          threshold = lib.mkDefault 3;
        };
        git_commit.only_detached = false;
        git_commit.tag_disabled = false;
      };
    };
  };
}
