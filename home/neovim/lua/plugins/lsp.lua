return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				nil_ls = { mason = false },
				lua_ls = { mason = false },
				ccls = {},
				ocamllsp = { mason = false },
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
				nix = { "nixfmt" },
				python = { "isort", "black" },
				["*"] = { "trim_whitespace", "trim_newlines" },
			},
		},
		ft = "*",
	},

	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",
			{ "fredrikaverpil/neotest-golang", version = "*" }, -- Installation
		},
		opts = {
			adapters = {
				require("neotest-golang"), -- Registration
			},
		},
	},
}
