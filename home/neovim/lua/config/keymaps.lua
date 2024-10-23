-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local key = vim.keymap

vim.o.wildcharm = string.byte(vim.keycode("<C-z>"))
key.set("c", "<Up>",    function() if vim.fn.wildmenumode() ~= 0 then return "<Left>"  else return "<Up>"    end end, { expr = true })
key.set("c", "<Down>",  function() if vim.fn.wildmenumode() ~= 0 then return "<Right>" else return "<Down>"  end end, { expr = true })
key.set("c", "<Left>",  function() if vim.fn.wildmenumode() ~= 0 then return "<Up>"    else return "<Left>"  end end, { expr = true })
key.set("c", "<Right>", function() if vim.fn.wildmenumode() ~= 0 then return "<Down>"  else return "<Right>" end end, { expr = true })
key.set("c", "<A-BS>", "<C-w>", { desc = "Delete word" })

key.set({"n", "i"}, "<C-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev Buffer" })
key.set({"n", "i"}, "<C-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next Buffer" })

-- Keep normal vim H/L for head/last line (along with M for mid)
key.del("n", "<S-h>")
key.del("n", "<S-l>")

-- Remove terminal mode mappins which override C-k kill line, C-l clear screen
key.del("t", "<C-j>")
key.del("t", "<C-h>")
key.del("t", "<C-k>")
key.del("t", "<C-l>")

-- Remove j/k mapped to gj/gk (though leave it for arrow keys)
key.del({ "n", "x" }, "j")
key.del({ "n", "x" }, "k")
