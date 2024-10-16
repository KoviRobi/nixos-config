-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local key = vim.keymap

key.set({"n", "i", "t"}, "<A-h>", "<cmd>wincmd h<cr>", { desc = "Go to Left Window" })
key.set({"n", "i", "t"}, "<A-j>", "<cmd>wincmd j<cr>", { desc = "Go to Lower Window" })
key.set({"n", "i", "t"}, "<A-k>", "<cmd>wincmd k<cr>", { desc = "Go to Upper Window" })
key.set({"n", "i", "t"}, "<A-l>", "<cmd>wincmd l<cr>", { desc = "Go to Right Window" })

key.set("n", "<C-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev Buffer" })
key.set("n", "<C-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next Buffer" })

key.del("n", "<S-h>")
key.del("n", "<S-l>")
key.del("t", "<C-j>")
key.del("t", "<C-h>")
key.del("t", "<C-k>")
key.del("t", "<C-l>")
key.del({ "n", "x" }, "j")
key.del({ "n", "x" }, "k")
