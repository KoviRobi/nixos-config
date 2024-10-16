local parser_install_dir = vim.fs.joinpath(vim.fn.stdpath('data'), 'tree-sitter', 'parsers')
vim.opt.runtimepath:prepend(parser_install_dir)

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      auto_install = false,
      ensure_installed = {},
      parser_install_dir = parser_install_dir,
    },
  },
}
