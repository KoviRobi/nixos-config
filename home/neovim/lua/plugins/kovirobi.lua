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
      { "n", "<F6>", ":UndotreeToggle<CR>", desc = "Undotree" }
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
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        ["*"] = { "trim_whitespace", "trim_newlines" },
      },
    },
  },
}
