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
		opts = function()
			require("neotest").setup({
				require("neotest-golang"), -- Registration
			})
		end,
	},

	{
		"mfussenegger/nvim-dap",
		setup = function()
			local dap = require("dap")
			dap.adapters.gdb = {
				type = "executable",
				command = "gdb",
				args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
			}
			local c_like = { "c", "cpp" }
			for _, language in ipairs(c_like) do
				dap.configurations[language] = {
					{
						name = "Launch",
						type = "gdb",
						request = "launch",
						program = function()
							return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
						end,
						cwd = "${workspaceFolder}",
						stopAtBeginningOfMainSubprogram = false,
					},
					{
						name = "Select and attach to process",
						type = "gdb",
						request = "attach",
						program = function()
							return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
						end,
						pid = function()
							local name = vim.fn.input("Executable name (filter): ")
							return require("dap.utils").pick_process({ filter = name })
						end,
						cwd = "${workspaceFolder}",
					},
					{
						name = "Attach to gdbserver",
						type = "gdb",
						request = "attach",
						target = function()
							return vim.fn.input("Target", ":3333")
						end,
						program = function()
							return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
						end,
						cwd = "${workspaceFolder}",
					},
				}
			end
		end,
	},
}
