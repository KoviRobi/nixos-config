# vim: set ts=2 sts=2 sw=2 et :
self: super:
let vimplugin = self.vimUtils.buildVimPluginFrom2Nix;
in
{
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
          set omnifunc=ale#completion#OmniFunc

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
          nnoremap <F7> :TagbarToggle<cr>

          let g:easytags_cmd = "${self.universal-ctags}/bin/ctags"
          let g:easytags_async = 1
          let g:tagbar_ctags_bin = "${self.universal-ctags}/bin/ctags"

          " Elixir
          let g:ale_linters = { 'elixir' : ['elixir-ls'] }
          let g:ale_linters.python = ['jedils', 'mypy']
          let g:ale_fixers = { '*': ['remove_trailing_lines', 'trim_whitespace'] }
          let g:ale_fixers.elixir = ['mix_format', 'remove_trailing_lines', 'trim_whitespace']
          let g:ale_elixir_elixir_ls_release = expand("~/elixir-ls/rel/")
          let g:ale_fixers.nix = ['nixpkgs-fmt', 'remove_trailing_lines', 'trim_whitespace']
          let g:ale_fixers.python = ['black', 'isort', 'remove_trailing_lines', 'trim_whitespace']
          let g:ale_fixers.html = ['prettier', 'remove_trailing_lines', 'trim_whitespace']
          let g:ale_fixers.css = ['prettier', 'remove_trailing_lines', 'trim_whitespace']
          let g:ale_fixers.javascript = ['prettier', 'remove_trailing_lines', 'trim_whitespace']
          let g:ale_fix_on_save = 1

          nmap <silent> gd :ALEGoToDefinition<CR>
          nmap <silent> gy :ALEGoToTypeDefinition<CR>
          nmap <silent> gr :ALEFindReferences<CR>
          nnoremap <silent> K :call <SID>show_documentation()<CR>

          function! s:show_documentation()
            if (index(['vim','help'], &filetype) >= 0)
              execute 'h '.expand('<cword>')
            else
              ALEHover
            endif
          endfunction

          let g:slime_target = "tmux"

          if filereadable(expand("$HOME/.config/nvim/init.vim"))
            source ~/.config/nvim/init.vim
          endif

          :packadd vim-localvimrc

          :packadd termdebug
          hi debugPC cterm=bold ctermfg=11 ctermbg=0 guifg=Cyan
          nmap <leader>db :Break<Cr>
          nmap <leader>dB :Clear<Cr>
          nmap <leader>dc :Continue<Cr>
          nmap <leader>di :Step<Cr>
          nmap <leader>do :Over<Cr>
          map  <leader>de :Evaluate<Cr>

          " Gitgutter and other gutter backgrounds
          hi SignColumn ctermbg=8
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
              vim-gitgutter
              vim-localvimrc
              ultisnips
              vim-snippets
              vim-elixir
              ale
              quickfix-reflector-vim
              vim-projectionist
              vim-test
              neoterm
              vim-textobj-user
              vim-textobj-elixir
              vim-fetch
              vim-bindsplit
              vimproc
              vim-unstack
              vim-slime
              literate-vim
              vim-test
            ];
            opt = [ ];
          };
      };
  };
}
