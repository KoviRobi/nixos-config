# vim: set ts=2 sts=2 sw=2 et :
self: super:
let vimplugin = self.vimUtils.buildVimPluginFrom2Nix;
in
{
  vim-fetch = vimplugin {
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

  coc-elixir = vimplugin {
    pname = "coc-elixir";
    version = "2020-07-19";
    src = self.fetchFromGitHub {
      owner = "elixir-lsp";
      repo = "coc-elixir";
      rev = "ee2e2b24db4354f506b1cc55093f23d6f424eaaa";
      sha256 = "1cicv6b0m63mriz7anh3bim852lb0vvrhmlf048h36mrqsaw2130";
    };
  };

  vim-textobj-elixir = vimplugin {
    pname = "vim-textobj-elixir";
    version = "2019-05-30";
    src = self.fetchFromGitHub {
      owner = "andyl";
      repo = "vim-textobj-elixir";
      rev = "b3d0fb1f19a918449eba856dc096c9f3231e871c";
      sha256 = "0nhcssbcdz1p5cjnd7v9fqa74288gm4y54v47fan9f6fx76sbd25";
    };
  };

  neovim = super.neovim.override {
    configure =
      {
        customRC = ''
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
          " Full config: when writing or reading a buffer, and on changes in insert and
          " normal mode (after 500ms; no delay when writing).
          call neomake#configure#automake('nrwi', 500)

          set background=dark
          colorscheme solarized

          nnoremap <F6> :UndotreeToggle<cr>
          nnoremap <F7> :TagbarToggle<cr>

          let g:easytags_cmd = "${self.universal-ctags}/bin/ctags"
          let g:easytags_async = 1
          let g:tagbar_ctags_bin = "${self.universal-ctags}/bin/ctags"

          " Elixir
          let g:neomake_elixir_enabled_makers = []
          let g:coc_node_path = "${self.nodejs}/bin/node"
          let g:ale_linters = { 'elixir' : [] }
          let g:ale_fixers = { '*': ['remove_trailing_lines', 'trim_whitespace'] }
          let g:ale_fixers.elixir = ['mix_format', 'remove_trailing_lines', 'trim_whitespace']
          let g:ale_fixers.nix = ['nixpkgs-fmt', 'remove_trailing_lines', 'trim_whitespace']
          let g:ale_fixers.python = ['black', 'remove_trailing_lines', 'trim_whitespace']
          let g:ale_fix_on_save = 1

          nmap <silent> gd <Plug>(coc-definition)
          nmap <silent> gr <Plug>(coc-references)
          nnoremap <silent> K :call <SID>show_documentation()<CR>

          function! s:show_documentation()
            if (index(['vim','help'], &filetype) >= 0)
              execute 'h '.expand('<cword>')
            else
              call CocAction('doHover')
            endif
          endfunction

          nnoremap <silent> <leader>co  :<C-u>CocList outline<CR>

          let g:slime_target = "tmux"

          if filereadable(expand("$HOME/.config/nvim/init.vim"))
            source ~/.config/nvim/init.vim
          endif
        '';
        packages.myVimPackage = with self.vimPlugins;
          {
            start = [
              undotree
              vim-easy-align
              solarized
              neomake
              vim-addon-nix
              vim-nix
              vim-easytags
              tagbar
              vim-fugitive
              vim-localvimrc
              ultisnips
              vim-snippets
              vim-elixir
              ale
              coc-nvim
              self.coc-elixir
              quickfix-reflector-vim
              vim-projectionist
              vim-test
              neoterm
              vim-textobj-user
              self.vim-textobj-elixir
              self.vim-fetch
              self.vim-blindsplit
              self.vim-literate
              vim-slime
            ];
            opt = [ ];
          };
      };
  };
}
