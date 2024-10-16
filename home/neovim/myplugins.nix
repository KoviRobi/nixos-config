{ vimPlugins, buildVimPlugin, fetchFromGitHub }:
let
  mkPlugin = conf:
    if vimPlugins ? vim-bindsplit
    then throw "Plugin merged upstream, this can be removed"
    else
      buildVimPlugin conf;
in
{
  vim-bindsplit =
    mkPlugin {
      pname = "vim-bindsplit";
      version = "2022-01-29";
      src = fetchFromGitHub {
        owner = "KoviRobi";
        repo = "vim-bindsplit";
        rev = "c28cc3a402dd9adbaad97b6389979783a2fab555";
        sha256 = "1dlj2dg4lns46m6dhdd13pbnwkjbm81ks35l6xnqm446sgzmh6qm";
      };
      meta.homepage = "https://github.com/KoviRobi/vim-bindsplit/";
    };

  maxmx03-solarized-nvim =
    mkPlugin {
      pname = "solarized.nvim";
      version = "3.5.0";
      src = fetchFromGitHub {
        owner = "maxmx03";
        repo = "solarized.nvim";
        rev = "f85f000c3e46714fee52cee3adf9f9661a048e40";
        hash = "sha256-1k5uK1Ge9zfNHeHxlg6rWdxlnvk45m5zwvWIYEyN1rg=";
      };
    };
}
