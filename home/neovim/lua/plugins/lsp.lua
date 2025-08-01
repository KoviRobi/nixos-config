return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			inlay_hints = { enabled = false },
			servers = {
				nil_ls = {
					mason = false,
					settings = {
						["nil"] = { nix = { flake = { autoArchive = false } } },
					},
				},
				lua_ls = { mason = false },
				ccls = {},
				ocamllsp = { mason = false },
				gopls = {},
				pyright = {},
				neocmake = {},
				tinymist = { mason = false },
			},
		},
	},

	{
		"chomosuke/typst-preview.nvim",
		ft = "typst",
	},

	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				nix = { "nixfmt" },
				python = { "isort", "black" },
				rust = { "rustfmt" },
				c = { "clang-format" },
				cpp = { "clang-format" },
				ocaml = { "ocamlformat", "trim_whitespace", "trim_newlines" },
				["*"] = function(bufnr)
					local ft = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
					if ft == "diff" or ft == "patch" then
						return {}
					else
						return { "trim_whitespace", "trim_newlines" }
					end
				end,
			},
			default_format_opts = {
				lsp_format = "fallback",
			},
		},
		ft = "*",
	},

	{ "nvim-treesitter/nvim-treesitter", enabled = false },

	{ "nvim-neotest/neotest", enabled = false },

	{
		"mfussenegger/nvim-dap",
		config = function(_dap, _opts)
			local dap = require("dap")
			dap.adapters.gdb = {
				type = "executable",
				command = "gdb",
				args = { "--quiet", "--interpreter=dap", "--eval-command", "set print pretty on" },
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

	{ "Civitasv/cmake-tools.nvim", config = {} },
}
