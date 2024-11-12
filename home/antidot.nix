# Stolen from https://github.com/doron-cohen/antidot/blob/4ab9a5794c568310c108e9904a9d710dce0d705d/rules.yaml
{ config, ... }:
{
  home = {
    shellAliases = {
      wget = "wget --hsts-file=${config.xdg.stateHome}/wget-hsts";
    };
    sessionVariables = {
      XCOMPOSECACHE = "${config.xdg.configHome}/x11/xcompose";
      GNUPGHOME = "${config.xdg.configHome}/gnupg";
      INPUTRC = "${config.xdg.configHome}/readline/inputrc";
      PASSWORD_STORE_DIR = "${config.xdg.configHome}/password-store";
    };
    file.".inputrc".target = "${config.xdg.configHome}/readline/inputrc";
  };
  programs.bash.historyFile = "${config.xdg.configHome}/bash/history";
}
