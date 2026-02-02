{
  config,
  lib,
  pkgs,
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
      plugins = [ pkgs.vimPlugins.gruvbox ];
      initLua = ''
        local brightness = "light"
        local fpath = vim.fs.dirname(vim.fn.stdpath("state")) .. "/brightness"
        local fp = io.open(fpath, "r")
        if fp ~= nil then
          local fread = fp:read():gsub("^%s+", ""):gsub("%s+$", "")
          if fread == "light" or fread == "dark" then
            brightness = fread
          end
        end
        vim.o.background = brightness
        vim.api.nvim_create_autocmd({ "VimEnter" }, {
          callback = function()
            vim.cmd.colorscheme("gruvbox")
          end,
        })
      '';
    };
  };
}
