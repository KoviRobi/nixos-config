-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local key = vim.keymap
local gs = require("gitsigns")

vim.o.wildcharm = string.byte(vim.keycode("<C-z>"))
key.set("c", "<Up>", function()
	if vim.fn.wildmenumode() ~= 0 then
		return "<Left>"
	else
		return "<Up>"
	end
end, { expr = true })
key.set("c", "<Down>", function()
	if vim.fn.wildmenumode() ~= 0 then
		return "<Right>"
	else
		return "<Down>"
	end
end, { expr = true })
key.set("c", "<Left>", function()
	if vim.fn.wildmenumode() ~= 0 then
		return "<Up>"
	else
		return "<Left>"
	end
end, { expr = true })
key.set("c", "<Right>", function()
	if vim.fn.wildmenumode() ~= 0 then
		return "<Down>"
	else
		return "<Right>"
	end
end, { expr = true })
key.set("c", "<A-BS>", "<C-w>", { desc = "Delete word" })
key.set("!", "<C-o>", "<Down>", { desc = "Omnicomplete next" })

key.set({ "n", "i" }, "<C-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev Buffer" })
key.set({ "n", "i" }, "<C-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next Buffer" })

-- Keep normal vim H/L for head/last line (along with M for mid)
key.del("n", "<S-h>")
key.del("n", "<S-l>")

-- Remove terminal mode mappins which override C-k kill line, C-l clear screen
key.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Normal mode" })

-- Remove j/k mapped to gj/gk (though leave it for arrow keys)
key.del({ "n", "x" }, "j")
key.del({ "n", "x" }, "k")

key.set("n", "<Leader>cO", function()
	local filter = { bufnr = vim.fn.bufnr() }
	local enabled = vim.diagnostic.is_enabled(filter)
	vim.diagnostic.enable(not enabled, filter)
end, { desc = "Toggle diagnostics for this buffer" })

key.set("n", "<Leader>gca", "<Cmd>Git commit --amend<CR>")
key.set("n", "<Leader>gcc", "<Cmd>Git commit<CR>")
key.set("n", "<Leader>gc<Space>", ":<C-U>Git commit")

key.set("n", "]H", function()
	if vim.wo.diff then
		vim.cmd.normal({ "]c", bang = true })
	else
		gs.nav_hunk("next", { target = "all" })
	end
end, { desc = "Next Hunk (staged or unstaged)" })
key.set("n", "[H", function()
	if vim.wo.diff then
		vim.cmd.normal({ "[c", bang = true })
	else
		gs.nav_hunk("prev", { target = "all" })
	end
end, { desc = "Prev Hunk (staged or unstaged)" })
