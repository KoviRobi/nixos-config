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
          ssh_symbol = builtins.fromJSON ''"\b\b🖧 "'';
          format = "[🖳 $ssh_symbol$hostname]($style) in ";
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
        battery.display = [
          { threshold = 100; style = "green"; }
          { threshold = 50; style = "bold italic green"; }
          { threshold = 40; style = "yellow"; }
          { threshold = 30; style = "bold italic yellow"; }
          { threshold = 20; style = "red"; }
          { threshold = 10; style = "bold italic red"; }
        ];
        custom.kakoune = {
          symbol = "🐈";
          command = "kcr prompt";
          when = "kcr prompt";
          shell = [ "sh" ];
          description = "The current Kakoune session and client";
          style = "green";
          format = "[$symbol$output]($style) ";
        };
      };
    };
  };
}
