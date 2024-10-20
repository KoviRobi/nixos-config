return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "solarized",
    }
  },
  { "tpope/vim-fugitive" },
  {
    "embear/vim-localvimrc",
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
    end,
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
      { "<A-h>", "<cmd>TmuxNavigateLeft<cr>", {"n", "i", "t"}, { desc = "Go to left window" }},
      { "<A-j>", "<cmd>TmuxNavigateDown<cr>", {"n", "i", "t"}, { desc = "Go to lower window" }},
      { "<A-k>", "<cmd>TmuxNavigateUp<cr>", {"n", "i", "t"}, { desc = "Go to upper window" }},
      { "<A-l>", "<cmd>TmuxNavigateRight<cr>", {"n", "i", "t"}, { desc = "Go to right window" }},
      { "<A-;>", "<cmd>TmuxNavigatePrevious<cr>", {"n", "i", "t"}, { desc = "Go to previous window" }},
    },
  },

  { "ii14/neorepl.nvim" },

  {
    "ms-jpq/coq_nvim",
    init = function()
      vim.g.coq_settings = {
        auto_start = 'shut-up',
        keymap = {
          recommended = false,
          jump_to_mark = "",
        },
      }
    end,
  },
}
