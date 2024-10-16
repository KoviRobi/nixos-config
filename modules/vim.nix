# vim: set ts=2 sts=2 sw=2 et :
{ config, lib, pkgs, ... }:

with lib;
let
  inherit (pkgs.vimUtils) buildVimPlugin;
  inherit (pkgs) fetchFromGitHub;
  literate-vim =
    if pkgs.vimPlugins ? literate-vim
    then throw "Plugin merged upstream, this can be removed"
    else
      buildVimPlugin {
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
      buildVimPlugin {
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
      buildVimPlugin {
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
      buildVimPlugin {
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

      set  showfulltag
      set completeopt=menuone,longest

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
      set grepprg=rg\ --vimgrep\ $*
      set virtualedit=block

      set background=light
      colorscheme solarized
      hi clear SpellBad
      hi clear SpellRare
      hi clear SpellLocal
      hi clear SpellCap
      hi SpellBad  cterm=undercurl
      hi SpellRare cterm=undercurl
      hi SpellCap  cterm=undercurl

      nnoremap <F6> :UndotreeToggle<cr>
      nnoremap <F7> :TagbarToggle<cr>

      let g:easytags_cmd = "${pkgs.universal-ctags}/bin/ctags"
      let g:easytags_async = 1
      let g:tagbar_ctags_bin = "${pkgs.universal-ctags}/bin/ctags"

      let g:netrw_keepj = ""

      let g:slime_target = "neovim"

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
      autocmd TermOpen * set nonumber norelativenumber
      autocmd BufReadCmd *.whl call zip#Browse(expand("<amatch>"))
      autocmd FileType git set foldmethod=syntax
      autocmd FileType gitcommit set foldmethod=syntax

      command -nargs=* Glg Git log --graph --oneline <args>
      command -nargs=* Gpf Git push --force-with-lease <args>

      set foldmethod=expr
      set foldlevelstart=10
      set foldcolumn=auto

      let g:typst_cmd = "typst"

      lua <<EOF
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'ocaml',
        callback = function(ev)
          vim.lsp.start({
            name = 'ocamllsp',
            cmd = {'ocamllsp'},
            root_dir = vim.fs.root(ev.buf, {'dune', '.git'}),
          })
        end,
      })

      vim.api.nvim_create_autocmd('FileType', {
        pattern = {'c', 'cpp'},
        callback = function(ev)
          vim.lsp.start({
            name = 'ccls',
            cmd = {'ccls'},
            root_dir = vim.fs.root(ev.buf, {'.ccls', '.git'}),
          })
        end,
      })

      vim.api.nvim_create_autocmd('FileType', {
        pattern = {'rust'},
        callback = function(ev)
          vim.lsp.start({
            name = 'rust-analyzer',
            cmd = {'rust-analyzer'},
            root_dir = vim.fs.root(ev.buf, {'Cargo.toml', '.git'}),
          })
        end,
      })

      vim.api.nvim_create_autocmd('FileType', {
        pattern = {'cmake'},
        callback = function(ev)
          vim.lsp.start({
            name = 'neocmakelsp',
            cmd = {'neocmakelsp'},
            root_dir = vim.fs.root(ev.buf, {'CMakeLists.txt', '.git'}),
          })
        end,
      })

      vim.api.nvim_create_autocmd('FileType', {
        pattern = {'go'},
        callback = function(ev)
          vim.lsp.start({
            name = 'gopls',
            cmd = {'gopls'},
            root_dir = vim.fs.root(ev.buf, {'go.mod', '.git'}),
          })
        end,
      })

      vim.api.nvim_create_autocmd('FileType', {
        pattern = {'typst'},
        callback = function(ev)
          vim.lsp.start({
            name = 'typst-lsp',
            cmd = {'typst-lsp'},
            root_dir = vim.fs.root(ev.buf, {'.git'}),
          })
        end,
      })

      vim.api.nvim_create_autocmd('FileType', {
        pattern = {'nix'},
        callback = function(ev)
          vim.lsp.start({
            name = 'nil',
            cmd = {'nil'},
            root_dir = vim.fs.root(ev.buf, {'flake.nix', '.git'}),
          })
        end,
      })
      EOF
    '';

    vim.plugins.start = with pkgs.vimPlugins;
      [
        undotree
        vim-easy-align
        nvim-solarized-lua
        neomake
        vim-addon-nix
        vim-nix
        vim-easytags
        tagbar
        vim-fugitive
        vim-gitgutter
        vim-localvimrc
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
        typst-vim

        literate-vim
        vim-bindsplit
        vim-textobj-elixir
        vim-unstack
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
