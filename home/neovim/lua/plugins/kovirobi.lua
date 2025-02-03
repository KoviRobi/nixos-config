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
					SpellBad = { undercurl = true, strikethrough = false },
				}
			end,
		},
		config = function(_, opts)
			vim.o.termguicolors = true

			local brightness = "light"
			local fpath = vim.fs.dirname(vim.fn.stdpath("state")) .. "/brightness"
			local fp = io.open(fpath, "r")
			if fp ~= nil then
				local fread = fp:read():gsub("^%s+", ""):gsub("%s+$", "")
				if fread == "light" or fread == "dark" then
					brightness = fread
				end
			end
			vim.o.background = brightness

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
		-- stylua: ignore
		cmd = {
			"G", "Git", "Ggrep", "Glgrep",
			"Gclog", "Gllog",
			"Gcd", "Glcd",
			"Ge", "Gedit", "Gsplit", "Gvsplit", "Gtabedit", "Gpedit",
			"Gdrop", "Gread", "Gwrite", "Gwq",
			"Gdiffsplit", "Gvdiffsplit", "Ghdiffsplit",
			"GMove", "GRename",
			"GDelete", "GRemove", "GUnlink",
			"GBrowse",
		},
		keys = {
			{
				"<C-R><C-G>",
				"fnameescape(fugitive#Object(@%))",
				mode = "c",
				desc = "Current fugitive object",
				expr = true,
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
			vim.g.slime_python_ipython = 0
			vim.g.slime_bracketed_paste = 1
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

	-- Overrides i_<C-Y>, plus just annoying (lack of `.` support, plus "```sh"
	-- completes in markdown, visual spam for suggestions)
	{
		"saghen/blink.cmp",
		enabled = false,
	},

	{
		"miversen33/netman.nvim",
		lazy = false,
	},

	{
		"nvim-neo-tree/neo-tree.nvim",
		lazy = false,
		dependencies = {
			"miversen33/netman.nvim",
		},
		opts = {
			sources = {
				"filesystem",
				"buffers",
				"git_status",
				"netman.ui.neo-tree",
			},
			filesystem = {
				hijack_netrw_behavior = "open_default",
			},
		},
	},

	{
		"folke/flash.nvim",
		---@type Flash.Config
		config = {
			modes = {
				char = {
					-- Allow using f/t for fresh search
					char_actions = function()
						return {
							[";"] = "next", -- set to `right` to always go right
							[","] = "prev", -- set to `left` to always go left
						}
					end,
				},
			},
		},
	},

	{
		"diefans/notmuch-vim",
		cmd = { "NotMuch" },
	},

	{
		"gyim/vim-boxdraw",
		-- stylua: ignore
		keys = {
			-- Box drawing
			{ "+o",   '<Cmd>call boxdraw#Draw("+o", [])<CR>',            mode = "v", desc = "Draw a rectangle, clear its contents with whitespace." },
			{ "+O",   '<Cmd>call boxdraw#DrawWithLabel("+O", [])<CR>',   mode = "v", desc = "Draw a rectangle, fill it with a label (middle center)." },
			{ "+[O",  '<Cmd>call boxdraw#DrawWithLabel("+[O", [])<CR>',  mode = "v", desc = "Draw a rectangle, fill it with a label (middle left)." },
			{ "+]O",  '<Cmd>call boxdraw#DrawWithLabel("+]O", [])<CR>',  mode = "v", desc = "Draw a rectangle, fill it with a label (middle right)." },
			{ "+{[O", '<Cmd>call boxdraw#DrawWithLabel("+{[O", [])<CR>', mode = "v", desc = "Draw a rectangle, fill it with a label (top left)." },
			{ "+{]O", '<Cmd>call boxdraw#DrawWithLabel("+{]O", [])<CR>', mode = "v", desc = "Draw a rectangle, fill it with a label (top right)." },
			{ "+}[O", '<Cmd>call boxdraw#DrawWithLabel("+}[O", [])<CR>', mode = "v", desc = "Draw a rectangle, fill it with a label (bottom left)." },
			{ "+}]O", '<Cmd>call boxdraw#DrawWithLabel("+}]O", [])<CR>', mode = "v", desc = "Draw a rectangle, fill it with a label (bottom right)." },
			{ "+{O",  '<Cmd>call boxdraw#DrawWithLabel("+{O", [])<CR>',  mode = "v", desc = "Draw a rectangle, fill it with a label (top center)." },
			{ "+}O",  '<Cmd>call boxdraw#DrawWithLabel("+}O", [])<CR>',  mode = "v", desc = "Draw a rectangle, fill it with a label (bottom center)." },

			-- Labeling
			{ "+c",   '<Cmd>call boxdraw#DrawWithLabel("+c", [])<CR>',   mode = "v", desc = "Change label (middle center)." },
			{ "+[c",  '<Cmd>call boxdraw#DrawWithLabel("+[c", [])<CR>',  mode = "v", desc = "Change label (middle left)." },
			{ "+]c",  '<Cmd>call boxdraw#DrawWithLabel("+]c", [])<CR>',  mode = "v", desc = "Change label (middle right)." },
			{ "+{[c", '<Cmd>call boxdraw#DrawWithLabel("+{[c", [])<CR>', mode = "v", desc = "Change label (top left)." },
			{ "+{]c", '<Cmd>call boxdraw#DrawWithLabel("+{]c", [])<CR>', mode = "v", desc = "Change label (top right)." },
			{ "+}[c", '<Cmd>call boxdraw#DrawWithLabel("+}[c", [])<CR>', mode = "v", desc = "Change label (bottom left)." },
			{ "+}]c", '<Cmd>call boxdraw#DrawWithLabel("+}]c", [])<CR>', mode = "v", desc = "Change label (bottom right)." },
			{ "+{c",  '<Cmd>call boxdraw#DrawWithLabel("+{c", [])<CR>',  mode = "v", desc = "Change label (top center)." },
			{ "+}c",  '<Cmd>call boxdraw#DrawWithLabel("+}c", [])<CR>',  mode = "v", desc = "Change label (bottom center)." },
			{ "+D",   "<Cmd>echo boxdraw#debug()<CR>",                   mode = "v", desc = "Box draw debug" },

			-- Line drawing
			{ "+>", '<Cmd>call boxdraw#Draw("+>", [])<CR>', mode = "v", desc = "Draw a line, right arrow head." },
			{ "+<", '<Cmd>call boxdraw#Draw("+<", [])<CR>', mode = "v", desc = "Draw a line, left arrow head." },
			{ "+v", '<Cmd>call boxdraw#Draw("+v", [])<CR>', mode = "v", desc = "Draw a line, down small arrow head." },
			{ "+V", '<Cmd>call boxdraw#Draw("+v", [])<CR>', mode = "v", desc = "Draw a line, down large arrow head." },
			{ "+^", '<Cmd>call boxdraw#Draw("+^", [])<CR>', mode = "v", desc = "Draw a line, up arrow head." },

			{ "++>", '<Cmd>call boxdraw#Draw("++>", [])<CR>', mode = "v", desc = "Draw a line, double right arrow head." },
			{ "++<", '<Cmd>call boxdraw#Draw("++<", [])<CR>', mode = "v", desc = "Draw a line, double left arrow head." },
			{ "++v", '<Cmd>call boxdraw#Draw("++v", [])<CR>', mode = "v", desc = "Draw a line, double down small arrow head." },
			{ "++V", '<Cmd>call boxdraw#Draw("++v", [])<CR>', mode = "v", desc = "Draw a line, double down large arrow head." },
			{ "++^", '<Cmd>call boxdraw#Draw("++^", [])<CR>', mode = "v", desc = "Draw a line, double up arrow head." },

			{ "+-",   '<Cmd>call boxdraw#Draw("+-", [])<CR>',   mode = "v", desc = "Draw a line." },
			{ "+_",   '<Cmd>call boxdraw#Draw("+_", [])<CR>',   mode = "v", desc = "Draw a line." },
			{ "+\\|", '<Cmd>call boxdraw#Draw("+\\|", [])<CR>', mode = "v", desc = "Draw a line." },

			-- Selection
			{ "ao", '<Cmd>call boxdraw#Select("ao")<CR>', mode = "v", desc = "Select box with border." },
			{ "io", '<Cmd>call boxdraw#Select("io")<CR>', mode = "v", desc = "Select box without border." },
		},
	},
}
