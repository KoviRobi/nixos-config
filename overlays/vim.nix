# vim: set ts=2 sts=2 sw=2 et :
self: super:
{ vim-fetch = self.vimUtils.buildVimPluginFrom2Nix {
    pname = "vim-fetch";
    version = "2019-04-03";
    src = self.fetchFromGitHub {
      owner = "wsdjeg";
      repo = "vim-fetch";
      rev = "76c08586e15e42055c9c21321d9fca0677442ecc";
      sha256 = "0avcqjcqvxgj00r477ps54rjrwvmk5ygqm3qrzghbj9m1gpyp2kz";
    };
  };

  neovim = super.neovim.override {
    configure =
    { customRC = ''
        " goto-file creates new files
        map gf :e %:.:h/<cfile><CR>
        map gF :tabe %:.:h/<cfile><CR>

        set undofile undodir=$HOME/.vim/undo/
        set expandtab tabstop=2 softtabstop=2 shiftwidth=0
        set colorcolumn=80
        set backspace=indent,start,eol
        set completeopt=menuone,preview,longest
        set number relativenumber
        set spell spelllang=en_gb
        set mouse=ar
        set belloff=all
        set wildmode=list:longest
        set ignorecase smartcase
        set autoindent
        set laststatus=2
        set notitle

        set background=dark
        colorscheme solarized

        nnoremap <F6> :UndotreeToggle<cr>
      '';
      packages.myVimPackage = with self.vimPlugins;
      { start = [ undotree vim-easy-align solarized self.vim-fetch ];
        opt = [];
      };
    };
  };
}
