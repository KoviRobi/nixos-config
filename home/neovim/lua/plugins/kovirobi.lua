return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "solarized",
    }
  },
  {
    "tpope/vim-fugitive",
    cmd = {
      "G", "Git",
      "Ggrep", "Glgrep",
      "Gclog", "Gllog",
      "Gcd", "Glcd",
      "Ge", "Gedit",
      "Gsplit", "Gvsplit", "Gtabedit", "Gpedit",
      "Gdrop",
      "Gread",
      "Gwrite", "Gwq",
      "Gdiffsplit", "Gvdiffsplit", "Ghdiffsplit",
      "GMove", "GRename",
      "GDelete", "GRemove", "GUnlink",
      "GBrowse",
    },
  },
  {
    "KoviRobi/vim-localvimrc",
    init = function()
      vim.g.localvimrc_persistent = 1
      vim.g.localvimrc_persistence_file = vim.fs.joinpath(vim.fn.stdpath('data'), 'localvimrc_persistent')
    end,
  },

  {
    "mbbill/undotree",
    keys = {
      { "<F6>", ":UndotreeToggle<CR>", desc = "Undotree" }
    },
  },

  { "kaarmu/typst.vim", ft = "typst", },

  {
    "jpalardy/vim-slime",
    init = function()
      vim.g.slime_target = "neovim"
      vim.g.slime_no_mappings = 1
    end,
    cmd = {
      "SlimeSend",
      "SlimeConfig",
    },
    keys = {
      { "<C-c><C-c>", "<Plug>SlimeRegionSend<cr>", mode = "x", { desc = "Send region to terminal" } },
      { "<C-c><C-c>", "<Cmd>normal! vip<CR><Plug>SlimeRegionSend<CR>", { desc = "Send region to terminal" } },
      { "<C-c>v", "<Cmd>SlimeConfig<CR>", { desc = "Send region to terminal" } },
    },
  },

  {
    "christoomey/vim-tmux-navigator",
    init = function()
      vim.g.tmux_navigator_no_mappings = 1
    end,
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<M-h>", "<cmd>TmuxNavigateLeft<cr>",     mode = {"n", "i", "t"}, { desc = "Go to left window" }},
      { "<M-j>", "<cmd>TmuxNavigateDown<cr>",     mode = {"n", "i", "t"}, { desc = "Go to lower window" }},
      { "<M-k>", "<cmd>TmuxNavigateUp<cr>",       mode = {"n", "i", "t"}, { desc = "Go to upper window" }},
      { "<M-l>", "<cmd>TmuxNavigateRight<cr>",    mode = {"n", "i", "t"}, { desc = "Go to right window" }},
      { "<M-;>", "<cmd>TmuxNavigatePrevious<cr>", mode = {"n", "i", "t"}, { desc = "Go to previous window" }},
    },
  },

  {
    "ii14/neorepl.nvim",
    cmd = { "Repl", },
  },

  {
    "junegunn/vim-easy-align",
    cmd = { "EasyAlign", "LiveEasyAlign", },
  },
}
