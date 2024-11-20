return {
	{
		"maxmx03/solarized.nvim",
		lazy = false,
		priority = 1000,
		---@type solarized.config
		opts = {
			on_highlights = function(_, _)
				return {
					NonText = { link = "Comment" },
					Whitespace = { link = "Comment" },
				}
			end,
		},
		config = function(_, opts)
			vim.o.termguicolors = true
			vim.o.background = "light"
			require("solarized").setup(opts)
			vim.cmd.colorscheme("solarized")
		end,
	},

	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "solarized",
		},
	},
	{
		"tpope/vim-fugitive",
		cmd = {
			"G",
			"Git",
			"Ggrep",
			"Glgrep",
			"Gclog",
			"Gllog",
			"Gcd",
			"Glcd",
			"Ge",
			"Gedit",
			"Gsplit",
			"Gvsplit",
			"Gtabedit",
			"Gpedit",
			"Gdrop",
			"Gread",
			"Gwrite",
			"Gwq",
			"Gdiffsplit",
			"Gvdiffsplit",
			"Ghdiffsplit",
			"GMove",
			"GRename",
			"GDelete",
			"GRemove",
			"GUnlink",
			"GBrowse",
		},
		key = {
			{
				"<C-R><C-G>",
				"<Cmd>fnameescape(fugitive#Object(@%))<CR>",
				mode = "c",
				desc = "Current fugitive object",
			},
			{ "y<C-G>", "<Cmd>call setreg(v:register, fugitive#Object(@%))<CR>", { silent = true } },
		},
	},
	{
		"embear/vim-localvimrc",
		init = function()
			vim.g.localvimrc_persistent = 1
			vim.g.localvimrc_persistence_file = vim.fs.joinpath(vim.fn.stdpath("data"), "localvimrc_persistent")
		end,
	},

	{
		"mbbill/undotree",
		keys = {
			{ "<F6>", ":UndotreeToggle<CR>", desc = "Undotree" },
		},
	},

	{ "kaarmu/typst.vim", ft = "typst" },

	{
		"jpalardy/vim-slime",
		init = function()
			vim.g.slime_target = "neovim"
			vim.g.slime_no_mappings = 1
			vim.g.slime_config_defaults = vim.empty_dict()
			vim.g.slime_cell_delimiter = "```"
		end,
		cmd = {
			"SlimeSend",
			"SlimeSendCell",
			"SlimeConfig",
		},
		keys = {
			{ "<C-c><C-c>", "<Plug>SlimeRegionSend<cr>", mode = "x", desc = "Send region to terminal" },
			{ "<C-c><C-c>", "<Cmd>normal! vip<CR><Plug>SlimeRegionSend<CR>", desc = "Send region to terminal" },
			{ "<C-c>c", "<Plug>SlimeSendCell<cr>", desc = "Send cell to terminal" },
			{ "<C-c>v", "<Cmd>SlimeConfig<CR>", desc = "Configure vim-slime" },
			{
				"<C-c>r",
				"<Cmd>call slime#targets#neovim#SlimeAddChannel(string(bufnr()))<CR>",
				desc = "Add this buffer as a slime channel",
			},
			{
				"<C-c>R",
				"<Cmd>call slime#targets#neovim#SlimeClearChannel(string(bufnr()))<CR>",
				desc = "Remove this buffer as a slime channel",
			},
		},
	},

	{
		"christoomey/vim-tmux-navigator",
		init = function()
			vim.g.tmux_navigator_no_mappings = 1
			vim.g.tmux_navigator_disable_when_zoomed = 1
		end,
		cmd = {
			"TmuxNavigateLeft",
			"TmuxNavigateDown",
			"TmuxNavigateUp",
			"TmuxNavigateRight",
			"TmuxNavigatePrevious",
		},
		keys = {
			{ "<M-h>", "<cmd>TmuxNavigateLeft<cr>", mode = { "n", "i", "t" }, desc = "Go to left window" },
			{ "<M-j>", "<cmd>TmuxNavigateDown<cr>", mode = { "n", "i", "t" }, desc = "Go to lower window" },
			{ "<M-k>", "<cmd>TmuxNavigateUp<cr>", mode = { "n", "i", "t" }, desc = "Go to upper window" },
			{ "<M-l>", "<cmd>TmuxNavigateRight<cr>", mode = { "n", "i", "t" }, desc = "Go to right window" },
			{ "<M-;>", "<cmd>TmuxNavigatePrevious<cr>", mode = { "n", "i", "t" }, desc = "Go to previous window" },
		},
	},

	{
		"ii14/neorepl.nvim",
		cmd = { "Repl" },
	},

	{
		"junegunn/vim-easy-align",
		cmd = { "EasyAlign", "LiveEasyAlign" },
	},

	{ "wsdjeg/vim-fetch" },

	{ "powerman/vim-plugin-AnsiEsc", cmd = { "AnsiEsc" } },

	{ "KoviRobi/vim-bindsplit", cmd = { "Bindsplit" } },

	-- Disable noice as both not real-time and just annoying for `make` commands
	{
		"folke/noice.nvim",
		enabled = false,
	},

	{
		"nvimdev/dashboard-nvim",
		opts = function(_, opts)
			opts.hide = {
				statusline = false,
				tabline = false,
				winbar = false,
			}
			return opts
		end,
	},

	{ "pimalaya/himalaya-vim" },
}
