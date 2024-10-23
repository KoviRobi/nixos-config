return {
	{
		"akinsho/toggleterm.nvim",
		opts = {
			size = 15,
			open_mapping = [[<c-\>]],
			hide_numbers = true,
			shade_filetypes = {},
			shade_terminals = true,
			shading_factor = 2,
			start_in_insert = true,
			persist_mode = false, -- toggleterm will always be opened in insert mode
			insert_mappings = true,
			persist_size = true,
			direction = "horizontal",
			close_on_exit = true,
			shell = vim.o.shell,
			auto_scroll = false,
		},
	},
}
