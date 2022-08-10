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

      lua <<
      require'nvim-treesitter.configs'.setup {
        highlight = {
          -- `false` will disable the whole extension
          enable = true,

          -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
          -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
          -- Using this option may slow down your editor, and you may see some duplicate highlights.
          -- Instead of true it can also be a list of languages
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
        },
        rainbow = {
          enable = true,
          -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
          extended_mode = true,
          -- Do not enable for files with more than n lines, int
          max_file_lines = nil,
          -- table of hex strings
          -- colors = {},
          -- table of colour name strings
          -- termcolors = {}
        },
      }
      .

      set foldmethod=expr
      set foldexpr=nvim_treesitter#foldexpr()
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
        quickfix-reflector-vim
        vim-projectionist
        vim-test
        neoterm
        vim-textobj-user
        vim-fetch
        vimproc
        vim-slime
        vim-test
        editorconfig-nvim

        literate-vim
        vim-bindsplit
        vim-textobj-elixir
        vim-unstack

        (nvim-treesitter.withPlugins (plugins: builtins.attrValues plugins))
        nvim-ts-rainbow
        nvim-treesitter-context
        nvim-treesitter-textobjects
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
