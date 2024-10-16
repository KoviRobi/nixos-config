return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        nil_ls = { mason = false, },
        lua_ls = { mason = false, },
        ccls = {},
        ocamllsp = { mason = false, },
        gopls = {},
        rust_analyzer = {},
        pyright = {},
      },
    },
  },

  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = { "isort", "black" },
        ["*"] = { "trim_whitespace", "trim_newlines" },
      },
    },
  },
}
