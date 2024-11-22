{
  vimPlugins,
  buildVimPlugin,
  fetchFromGitHub,
}:
let
  mkPlugin =
    conf:
    if vimPlugins ? vim-bindsplit then
      throw "Plugin merged upstream, this can be removed"
    else
      buildVimPlugin conf;
in
{
  vim-bindsplit = mkPlugin {
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

  maxmx03-solarized-nvim = mkPlugin {
    pname = "solarized.nvim";
    version = "3.5.0";
    src = fetchFromGitHub {
      owner = "maxmx03";
      repo = "solarized.nvim";
      rev = "f85f000c3e46714fee52cee3adf9f9661a048e40";
      hash = "sha256-1k5uK1Ge9zfNHeHxlg6rWdxlnvk45m5zwvWIYEyN1rg=";
    };
  };

  profile-nvim = mkPlugin {
    pname = "profile.nvim";
    version = "unstable-2024-11-09";
    src = fetchFromGitHub {
      owner = "stevearc";
      repo = "profile.nvim";
      rev = "d57df512bdade4c7a04a1bb6c89c8b54c5dce52a";
      sha256 = "sha256-dRHidtV/M+i/5CkeaJBQ2BMuISmnrAIqm34x7YBkSNU=";
    };
    meta.homepage = "https://github.com/stevearc/profile.nvim";
  };

  himalaya-vim = mkPlugin {
    pname = "himalaya-vim";
    version = "unstable-2024-09-10";
    src = fetchFromGitHub {
      owner = "pimalaya";
      repo = "himalaya-vim";
      rev = "f25c003e8fe532348b4080bf8d738cfa1bbf1f5f";
      sha256 = "sha256-oQtl3VmLpZf+cj1YGLKHbxmaE5GFLEeDi2Z7g3mvZjc=";
    };
    meta.homepage = "https://github.com/pimalaya/himalaya-vim";
  };

  neotest-ctest = mkPlugin rec {
    pname = "neotest-ctest";
    version = "v0.1.0";
    src = fetchFromGitHub {
      owner = "orjangj";
      repo = pname;
      rev = version;
      sha256 = "sha256-+560CBPJeKd2F9qboI1YiccffQYLFoHpaEIs0HsCGls=";
    };
    meta.homepage = "https://github.com/orjangj/neotest-ctest";
  };
}
