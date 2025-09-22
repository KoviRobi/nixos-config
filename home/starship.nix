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
        format = builtins.fromJSON ''"\u001b\\]133;A\u001b\\\\$all$line_break$character\u001b\\]133;B\u001b\\\\"'';
        add_newline = false;
        aws.disabled = true;
        directory.truncation_symbol = "…/";
        hostname = {
          ssh_only = false;
          ssh_symbol = builtins.fromJSON ''"\b\b\b🖧  "'';
          format = "[🖳  $ssh_symbol$hostname]($style) in ";
          style = "bold green";
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
