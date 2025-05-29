-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local function augroup(name)
	return vim.api.nvim_create_augroup("kovirobi_" .. name, { clear = true })
end

-- fold git commits, I use commit.verbose = true
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("fold_git"),
	pattern = {
		"git",
		"gitcommit",
	},
	callback = function(event)
		vim.o.foldmethod = "syntax"
	end,
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("close_with_q"),
	pattern = {
		"fugutive",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<cr>", {
			buffer = event.buf,
			silent = true,
			desc = "Quit buffer",
		})
	end,
})

-- Take account of mini.misc gutter for :Man
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("man_mini_misc_width"),
	pattern = {
		"man",
	},
	callback = function(event)
		vim.o.foldmethod = "manual"
		vim.o.signcolumn = "no"
		vim.o.statuscolumn = ""
	end,
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufWinEnter" }, {
	pattern = "*.overlay",
	callback = function()
		vim.o.filetype = "dts"
	end,
})

-- Nix sw=2
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "nix" },
	callback = function()
		vim.o.shiftwidth = 2
	end,
})
