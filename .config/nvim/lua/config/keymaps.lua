-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- move lines in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { silent = true, desc = "moves lines in visual mode" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { silent = true, desc = "moves lines in visual mode" })

-- Copy only available into Neovim
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { silent = true, desc = "Copy only available into Neovim" })
-- Copy available in and outside of Neovim
vim.keymap.set("n", "<leader>Y", [["+Y]], { silent = true, desc = "Copy available in and outside of Neovim" })

-- replace the highlited word
vim.keymap.set(
  "n",
  "<leader>s",
  [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { silent = true, desc = "replace the highlited word" }
)

-- use jk and kj to exit insert mode
vim.keymap.set("i", "jk", "<ESC>", { silent = true, desc = "Exit insert mode" })
-- vim.keymap.set("i", "kj", "<ESC>", { silent = true, desc = "Exit insert mode" })

-- -- Perusing code faster with K and J
vim.keymap.set({ "n", "v" }, "K", "5k", { noremap = true, desc = "Up faster" })
vim.keymap.set({ "n", "v" }, "J", "5j", { noremap = true, desc = "Down faster" })

-- Remap K and J
vim.keymap.set({ "n", "v" }, "<leader>k", "K", { noremap = true, desc = "Keyword" })
vim.keymap.set({ "n", "v" }, "<leader>j", "J", { noremap = true, desc = "Join lines" })

-- clear search highlights
vim.keymap.set("n", "<leader>nh", ":nohl<CR>", { silent = true, desc = "clear search highlights" })
-- delete single character without copying into register
vim.keymap.set("n", "x", '"_x', { silent = true, desc = "delete single character without copying into register" })

vim.keymap.set("n", "<leader>tx", ":tabclose<CR>", { silent = true, desc = "close current tab" }) -- close current tab

vim.api.nvim_set_keymap("n", "QQ", ":q!<enter>", { noremap = false, desc = "Quit all" })
vim.api.nvim_set_keymap("n", "WW", ":w!<enter>", { noremap = false, desc = "Save file" })

vim.keymap.set("n", "<C-x>", ":bd<CR>", { silent = false, desc = "Close current buffer" })

-- Unmap mappings used by tmux plugin
-- TODO(vintharas): There's likely a better way to do this.
vim.keymap.del("n", "<C-h>")
vim.keymap.del("n", "<C-j>")
vim.keymap.del("n", "<C-k>")
vim.keymap.del("n", "<C-l>")
vim.keymap.set("n", "<C-h>", "<cmd>TmuxNavigateLeft<cr>")
vim.keymap.set("n", "<C-j>", "<cmd>TmuxNavigateDown<cr>")
vim.keymap.set("n", "<C-k>", "<cmd>TmuxNavigateUp<cr>")
vim.keymap.set("n", "<C-l>", "<cmd>TmuxNavigateRight<cr>")

vim.keymap.set("n", "<leader>rn", function()
  return ":IncRename " .. vim.fn.expand("<cword>")
end, { expr = true })
