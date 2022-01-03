{ pkgs, config, lib, ... }:
{
  environment = {

    systemPackages = with pkgs; [
      starship
      exa
      dnsutils
      git
      bottom
      manix
      skim
      tealdeer
      ripgrep
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
          time.disabled = false;
        }
      }
    '';

    shellAliases =
      let ifSudo = lib.mkIf config.security.sudo.enable;
      in
      {
        # quick cd
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
        "....." = "cd ../../../..";

        # ls
        ls = "exa";
        l = "ls -l";
        ll = "ls -l";
        la = "ls -la";

        # git
        g = "git";

        # grep
        gi = "grep -i";

        # internet ip
        myip = "dig +short myip.opendns.com @208.67.222.222 2>&1";

        # nix
        n = "nix";
        np = "n profile";
        ni = "np install";
        nr = "np remove";
        ns = "n search --no-update-lock-file";
        nf = "n flake";
        nepl = "n repl '<nixpkgs>'";
        srch = "ns nixos";
        orch = "ns override";
        nrb = ifSudo "sudo nixos-rebuild";
        mn = ''
          manix "" | grep '^# ' | sed 's/^# \(.*\) (.*/\1/;s/ (.*//;s/^# //' | sk --preview="manix '{}'" | xargs manix
        '';

        # sudo
        s = ifSudo "sudo -E ";
        si = ifSudo "sudo -i";
        se = ifSudo "sudoedit";

        # top
        top = "btm";

        # systemd
        ctl = "systemctl";
        stl = ifSudo "s systemctl";
        utl = "systemctl --user";
        ut = "systemctl --user start";
        un = "systemctl --user stop";
        up = ifSudo "s systemctl start";
        dn = ifSudo "s systemctl stop";
        jtl = "journalctl";

      };
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
