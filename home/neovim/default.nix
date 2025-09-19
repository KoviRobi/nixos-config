{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.kovirobi.neovim;
in
{
  options.kovirobi.neovim = {
    enable = mkEnableOption "neovim";
  };

  config = mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      withNodeJs = true;
    };
  };
}
