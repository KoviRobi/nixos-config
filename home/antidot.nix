# Stolen from https://github.com/doron-cohen/antidot/blob/4ab9a5794c568310c108e9904a9d710dce0d705d/rules.yaml
{ config, ... }:
{
  home = {
    shellAliases = {
      wget = "wget --hsts-file=${config.xdg.cacheHome}/wget-hsts";
    };
    sessionVariables = {
      XCOMPOSECACHE = "${config.xdg.cacheHome}/x11/xcompose";
      GNUPGHOME = "${config.xdg.cacheHome}/gnupg";
      INPUTRC = "${config.xdg.cacheHome}/readline/inputrc";
    };
    file.".inputrc".target = "${config.xdg.cacheHome}/readline/inputrc";
  };
  programs.bash.historyFile = "${config.xdg.cacheHome}/bash/history";
}
