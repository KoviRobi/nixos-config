{
  pkgs,
  lib,
  ...
}:
{

  home.packages = with pkgs; [ starship ];

  programs = {
    zsh.initContent = lib.mkAfter ''
      if [[ $TERM != "dumb" ]]; then
            # Undo starship's default
            setopt NO_PROMPT_SUBST
            function set_win_title(){
                # Cache starship prompt
                PS1=$(/etc/profiles/per-user/rmk/bin/starship \
                    prompt \
                    --terminal-width="$COLUMNS" \
                    --keymap="''${KEYMAP:-}" \
                    --status="''${STARSHIP_CMD_STATUS:-}" \
                    --pipestatus="''${STARSHIP_PIPE_STATUS[*]:-}" \
                    --cmd-duration="''${STARSHIP_DURATION:-}" \
                    --jobs="$STARSHIP_JOBS_COUNT")

                printf '\x1b]0;%s\x07' \
                    "''$(echo $PS1 | sed -E \
                      -e ': 1 s/.\x08//; t 1' \
                      -e 's/%\{([^%]|%%)*%}//g' \
                      -e 's/%%/%/g' \
                      -e q)"
            }

            add-zsh-hook precmd set_win_title
      fi
    '';

    starship = {
      enable = true;
      # Handled manually to replace `= {` with `= {||`
      enableNushellIntegration = false;
      settings = {
        format = builtins.fromJSON (
          ''"\u001b\\]133;A\u001b\\\\\u001b\\[m''
          + "\${env_var.ZMX_SESSION}"
          + "\${env_var.SYSTEMD_EXEC_PID}"
          + "$all$line_break$character"
          + ''\u001b\\]133;B\u001b\\\\\u001b\\[m"''
        );
        env_var.ZMX_SESSION = {
          symbol = " ";
          format = "[$symbol$env_value]($style) ";
          description = "zmx session name";
          style = "";
        };
        env_var.SYSTEMD_EXEC_PID = {
          symbol = "󰱛 ";
          format = "[$symbol$env_value]($style) ";
          description = "systemd-run or similar ($SYSTEMD_EXEC_PID)";
          style = "bold purple";
        };
        add_newline = false;
        aws.disabled = true;
        directory.truncation_symbol = "…/";
        hostname = {
          ssh_only = false;
          ssh_symbol = builtins.fromJSON ''"\b\b🖧 "'';
          format = "[🖳 $ssh_symbol$hostname]($style) in ";
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
          {
            threshold = 100;
            style = "green";
          }
          {
            threshold = 50;
            style = "bold italic green";
          }
          {
            threshold = 40;
            style = "yellow";
          }
          {
            threshold = 30;
            style = "bold italic yellow";
          }
          {
            threshold = 20;
            style = "red";
          }
          {
            threshold = 10;
            style = "bold italic red";
          }
        ];
        nix_shell = {
          symbol = "❄ ";
          impure_msg = "󰕤";
          pure_msg = "󰕕";
        };
      };
    };
  };
}
