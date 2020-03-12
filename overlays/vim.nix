# vim: set ts=2 sts=2 sw=2 et :
self: super:
let vimplugin = self.vimUtils.buildVimPluginFrom2Nix;
in
{ vim-fetch = vimplugin {
    pname = "vim-fetch";
    version = "2019-04-03";
    src = self.fetchFromGitHub {
      owner = "wsdjeg";
      repo = "vim-fetch";
      rev = "76c08586e15e42055c9c21321d9fca0677442ecc";
      sha256 = "0avcqjcqvxgj00r477ps54rjrwvmk5ygqm3qrzghbj9m1gpyp2kz";
    };
  };

  vim-blindsplit = vimplugin {
    pname = "vim-bindsplit";
    version = "2016-01-05";
    src = self.fetchFromGitHub {
      owner = "jcorbin";
      repo = "vim-bindsplit";
      rev = "d0b642bdbfcabb7096b58249d3e1073456b54ef9";
      sha256 = "1n5ajmw20628z4pfxf6l45qynjwl9i6y5an36qk84nsa4jwr3xa7";
    };
  };

  vim-literate = vimplugin {
    pname = "literate.vim";
    version = "2018-05-17";
    src = self.fetchFromGitHub {
      owner = "zyedidia";
      repo = "literate.vim";
      rev = "4ffd45cb1657b67f4ed0eb639478a69209ec1f94";
      sha256 = "004zcb1p6qma8vlx08sfhp0q7vhc2mphqa6mwahl41lb6z58k62z";
    };
  };

  neovim = super.neovim.override {
    configure =
    { customRC = ''
        let mapleader = ","

        " goto-file creates new files
        map gf :e %:.:h/<cfile><CR>

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

        packadd neomake
        " When writing a buffer (no delay).
        call neomake#configure#automake('w')
        " When writing a buffer (no delay), and on normal mode changes (after 750ms).
        call neomake#configure#automake('nw', 750)
        " When reading a buffer (after 1s), and when writing (no delay).
        call neomake#configure#automake('rw', 1000)
        " Full config: when writing or reading a buffer, and on changes in insert and
        " normal mode (after 500ms; no delay when writing).
        call neomake#configure#automake('nrwi', 500)

        set background=dark
        colorscheme solarized

        nnoremap <F6> :UndotreeToggle<cr>
        nnoremap <F7> :TagbarToggle<cr>

        let g:easytags_cmd = "${self.universal-ctags}/bin/ctags"

        source ~/.config/nvim/init.vim
      '';
      packages.myVimPackage = with self.vimPlugins;
      { start = [ undotree vim-easy-align solarized neomake
                  vim-addon-nix vim-nix vim-easytags tagbar vim-localvimrc
                  self.vim-fetch self.vim-blindsplit self.vim-literate ];
        opt = [];
      };
    };
  };
}
