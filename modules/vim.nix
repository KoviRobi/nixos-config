# vim: set ts=2 sts=2 sw=2 et :
{ config, lib, pkgs, ... }:

with lib;
let
  inherit (pkgs.vimUtils) buildVimPluginFrom2Nix;
  inherit (pkgs) fetchFromGitHub;
  literate-vim =
    if pkgs.vimPlugins ? literate-vim
    then throw "Plugin merged upstream, this can be removed"
    else
      buildVimPluginFrom2Nix {
        pname = "literate.vim";
        version = "2018-05-17";
        src = fetchFromGitHub {
          owner = "zyedidia";
          repo = "literate.vim";
          rev = "4ffd45cb1657b67f4ed0eb639478a69209ec1f94";
          sha256 = "004zcb1p6qma8vlx08sfhp0q7vhc2mphqa6mwahl41lb6z58k62z";
        };
        meta.homepage = "https://github.com/zyedidia/literate.vim/";
      };

  vim-bindsplit =
    if pkgs.vimPlugins ? vim-bindsplit
    then throw "Plugin merged upstream, this can be removed"
    else
      buildVimPluginFrom2Nix {
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

  vim-textobj-elixir =
    if pkgs.vimPlugins ? vim-textobj-elixir
    then throw "Plugin merged upstream, this can be removed"
    else
      buildVimPluginFrom2Nix {
        pname = "vim-textobj-elixir";
        version = "2019-05-30";
        src = fetchFromGitHub {
          owner = "andyl";
          repo = "vim-textobj-elixir";
          rev = "b3d0fb1f19a918449eba856dc096c9f3231e871c";
          sha256 = "0nhcssbcdz1p5cjnd7v9fqa74288gm4y54v47fan9f6fx76sbd25";
        };
        meta.homepage = "https://github.com/andyl/vim-textobj-elixir/";
      };

  vim-unstack =
    if pkgs.vimPlugins ? vim-unstack
    then throw "Plugin merged upstream, this can be removed"
    else
      buildVimPluginFrom2Nix {
        pname = "vim-unstack";
        version = "2021-02-02";
        src = fetchFromGitHub {
          owner = "mattboehm";
          repo = "vim-unstack";
          rev = "9b191419b4d3f26225a5ae3df5e409c62b426941";
          sha256 = "192q163j9fsbkm1ns25mkwqhjznn5jajvfjzvsp623kdqlxnpc1b";
        };
        meta.homepage = "https://github.com/mattboehm/vim-unstack/";
      };

  gitmoji-vim =
    if pkgs.vimPlugins ? gitmoji-vim
    then throw "Plugin merged upstream, this can be removed"
    else
      buildVimPluginFrom2Nix {
        pname = "gitmoji-vim";
        version = "2022-10-30";
        src = fetchFromGitHub {
          owner = "bruxisma";
          repo = "gitmoji.vim";
          rev = "dba6f328a9a2d8de5c0b2f4e2791ff86ed725dc8";
          sha256 = "sha256-/D5uadQlKeckMhwE8MhXr48j8b+6zXmTW0JAP4GEK4s=";
        };
        meta.homepage = "https://github.com/bruxisma/gitmoji.vim/";
      };

  vim-nushell =
    if pkgs.vimPlugins ? vim-nushell
    then throw "Plugin merged upstream, this can be removed"
    else
      buildVimPluginFrom2Nix {
        pname = "vim-nushell";
        version = "2022-10-30";
        src = fetchFromGitHub {
          owner = "ErichDonGubler";
          repo = "vim-nushell";
          rev = "8e523ac5eec3336ec332fcb07d7a1bf3d1960fcb";
          sha256 = "sha256-17TDTqH6sMBI76S2FwZeixuYL/BIZ3hEnop2lYPnS3Q=";
        };
        meta.homepage = "https://github.com/bruxisma/gitmoji.vim/";
      };
in
{
  options.vim = {
    rc = mkOption {
      type = types.lines;
      default = "";
    };

    plugins.start =
      mkOption {
        type = types.listOf types.package;
        default = [ ];
        description = ''
          Vim packages to load at start
        '';
      };

    plugins.opt = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = ''
        Vim packages to load using `packadd`
      '';
    };
  };

  config = {
    vim.rc = ''
      let mapleader = ","

      " goto-file which creates new files
      map gcf :e <cfile><CR>

      set undofile undodir=$HOME/.vim/undo/
      set expandtab tabstop=2 softtabstop=2 shiftwidth=0
      set colorcolumn=80
      set cursorline cursorcolumn
      set backspace=indent,start,eol
      " Allows completing/gf on `VAR=/etc/path` style lines
      set isfname-==

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
      set scrolljump=5
      set grepprg=rg\ -nH\ $*

      set background=dark
      colorscheme solarized

      nnoremap <F6> :UndotreeToggle<cr>
      nnoremap <F7> :TagbarToggle<cr>

      let g:easytags_cmd = "${pkgs.universal-ctags}/bin/ctags"
      let g:easytags_async = 1
      let g:tagbar_ctags_bin = "${pkgs.universal-ctags}/bin/ctags"

      let g:netrw_keepj = ""

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

      nmap <silent> <C-W>gd :ALEGoToDefinition -tab<CR>
      nmap <silent> <C-W>gy :ALEGoToTypeDefinition -tab<CR>
      nmap <silent> <C-W>gr :ALEFindReferences -tab<CR>
      nmap <silent> gd :ALEGoToDefinition<CR>
      nmap <silent> gy :ALEGoToTypeDefinition<CR>
      nmap <silent> gr :ALEFindReferences<CR>
      nnoremap <silent> K :call <SID>show_documentation()<CR>
      nnoremap <silent> <C-Space> :ALECodeAction<CR>
      nmap <silent> [a <Plug>(ale_previous_wrap)
      nmap <silent> ]a <Plug>(ale_next_wrap)

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

      " Emacs-style keys, see `:help emacs-keys`
      " start of line
      :cnoremap <C-A>  <Home>
      " back one character
      :cnoremap <C-B>  <Left>
      " delete character under cursor
      :cnoremap <C-D>  <Del>
      " end of line
      :cnoremap <C-E>  <End>
      " forward one character
      :cnoremap <C-F>  <Right>
      " recall newer command-line
      :cnoremap <C-N>  <Down>
      " recall previous (older) command-line
      :cnoremap <C-P>  <Up>
      " back one word
      :cnoremap <A-b>  <S-Left>
      " forward one word
      :cnoremap <A-f>  <S-Right>
      " delete one word
      :cnoremap <A-BS> <C-w>

      " Easier navigation between windows, especially for Terminal-mode
      :tnoremap <A-h> <C-\><C-N><C-w>h
      :tnoremap <A-j> <C-\><C-N><C-w>j
      :tnoremap <A-k> <C-\><C-N><C-w>k
      :tnoremap <A-l> <C-\><C-N><C-w>l
      :inoremap <A-h> <C-\><C-N><C-w>h
      :inoremap <A-j> <C-\><C-N><C-w>j
      :inoremap <A-k> <C-\><C-N><C-w>k
      :inoremap <A-l> <C-\><C-N><C-w>l
      :nnoremap <A-h> <C-w>h
      :nnoremap <A-j> <C-w>j
      :nnoremap <A-k> <C-w>k
      :nnoremap <A-l> <C-w>l

      let g:neoterm_autoinsert = 1
      autocmd BufEnter term://* startinsert

      set foldmethod=expr
      set foldlevelstart=10
      set foldcolumn=auto
    '';

    vim.plugins.start = with pkgs.vimPlugins;
      [
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
        vimspector
        quickfix-reflector-vim
        vim-projectionist
        neoterm
        vim-textobj-user
        vim-fetch
        vimproc
        vim-slime
        vim-test
        editorconfig-nvim
        zig-vim
        zoxide-vim
        fzf-vim
        vim-plugin-AnsiEsc

        literate-vim
        vim-bindsplit
        vim-textobj-elixir
        vim-unstack
        gitmoji-vim
        vim-nushell
      ];

    nixpkgs.overlays = [
      (self: super: {
        neovim = super.neovim.override {
          configure.customRC = config.vim.rc;
          configure.packages.myVimPackage = {
            inherit (config.vim.plugins) start opt;
          };
        };
      })
    ];
  };
}
