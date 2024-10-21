{ config
, lib
, pkgs
, ...
}:
with lib; let
  cfg = config.kovirobi.neovim;
  myplugins = lib.callPackagesWith
    (pkgs // { inherit (pkgs.vimUtils) buildVimPlugin; })
    ./myplugins.nix
    { };
in
{
  options.kovirobi.neovim = {
    enable = mkEnableOption "neovim";
  };

  config = mkIf cfg.enable {
    home.sessionVariables = {
      EDITOR = "nvim";
    };

    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      withNodeJs = true;

      plugins = (with pkgs.vimPlugins; [
        # base distro
        LazyVim
        lazydev-nvim
        conform-nvim
        nvim-lint
        render-markdown-nvim
        headlines-nvim

        # theme
        dracula-nvim

        # UI
        bufferline-nvim
        gitsigns-nvim
        dashboard-nvim
        toggleterm-nvim
        trouble-nvim
        lualine-nvim
        which-key-nvim
        nvim-web-devicons
        mini-nvim
        noice-nvim
        nui-nvim
        nvim-notify
        nvim-lsp-notify
        neo-tree-nvim
        nvim-navic
        dressing-nvim
        aerial-nvim

        # project management
        project-nvim
        neoconf-nvim
        persistence-nvim

        # smart typing
        indent-blankline-nvim
        guess-indent-nvim
        vim-illuminate

        # LSP
        nvim-lspconfig
        rust-tools-nvim
        crates-nvim
        null-ls-nvim
        nvim-lightbulb # lightbulb for quick actions
        # nvim-code-action-menu # code action menu
        neodev-nvim
        SchemaStore-nvim # load known formats for json and yaml

        # snippets
        luasnip # snippet engine
        friendly-snippets # a bunch of snippets to use
        nvim-snippets

        # search functionality
        plenary-nvim
        telescope-nvim
        telescope-fzf-native-nvim
        nvim-spectre
        flash-nvim

        # treesitter
        ts-comments-nvim
        nvim-treesitter-context
        nvim-ts-autotag
        nvim-treesitter-textobjects
        nvim-treesitter.withAllGrammars

        # comments
        nvim-ts-context-commentstring
        todo-comments-nvim

        # leap
        vim-repeat
        leap-nvim
        flit-nvim

        # DAP
        nvim-dap
        nvim-dap-ui
        nvim-dap-virtual-text

        # neotest
        neotest
        neotest-rust

        # kovirobi
        undotree
        vim-fugitive
        vim-localvimrc
        vim-slime
        vim-tmux-navigator
        neorepl-nvim
        vim-easy-align

        lazy-nvim
        vim-startuptime
      ]) ++ (with myplugins; [
        # kovirobi
        vim-bindsplit
        maxmx03-solarized-nvim
      ]);

      extraPackages = with pkgs; [
        gcc # needed for nvim-treesitter

        # LazyVim defaults
        stylua
        shfmt

        # Markdown extra
        markdownlint-cli2
        marksman

        # Docker extra
        nodePackages.dockerfile-language-server-nodejs
        hadolint
        docker-compose-language-service

        # JSON and YAML extras
        nodePackages.vscode-json-languageserver
        nodePackages.yaml-language-server

        # Custom
        editorconfig-checker
        shellcheck

        lua-language-server

        statix
      ];

      extraLuaConfig = ''
        vim.g.mapleader = " "
        vim.o.background = "light" -- to prevent flashing on startup
        require("lazy").setup({
          spec = {
            { "LazyVim/LazyVim", import = "lazyvim.plugins" },
            -- import any extras modules here
            { import = "lazyvim.plugins.extras.dap.core" },
            { import = "lazyvim.plugins.extras.dap.nlua" },
            { import = "lazyvim.plugins.extras.editor.aerial" },
            { import = "lazyvim.plugins.extras.editor.leap" },
            { import = "lazyvim.plugins.extras.editor.navic" },
            { import = "lazyvim.plugins.extras.lang.docker" },
            { import = "lazyvim.plugins.extras.lang.json" },
            { import = "lazyvim.plugins.extras.lang.markdown" },
            { import = "lazyvim.plugins.extras.lang.rust" },
            { import = "lazyvim.plugins.extras.lang.yaml" },
            { import = "lazyvim.plugins.extras.test.core" },
            -- import/override with your plugins
            { import = "plugins" },
          },
          defaults = {
            -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
            -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
            lazy = false,
            -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
            -- have outdated releases, which may break your Neovim install.
            version = false, -- always use the latest git commit
            -- version = "*", -- try installing the latest stable version for plugins that support semver
          },
          performance = {
            -- Used for NixOS
            reset_packpath = false,
            rtp = {
              reset = false,
              -- disable some rtp plugins
              disabled_plugins = {
                "gzip",
                -- "matchit",
                -- "matchparen",
                -- "netrwPlugin",
                "tarPlugin",
                -- "tohtml",
                "tutor",
                -- "zipPlugin",
              },
            }
          },
          dev = {
            path = "${pkgs.vimUtils.packDir config.programs.neovim.finalPackage.passthru.packpathDirs}/pack/myNeovimPackages/start",
            patterns = {""},
          },
          install = {
            missing = false,
          },
        })
      '';
    };

    xdg.configFile."nvim/lua" = {
      recursive = true;
      source = ./lua;
    };
  };
}
