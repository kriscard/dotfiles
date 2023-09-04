-- set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

---------------------
-- General Keymaps
---------------------
-- Desactivate the arrow, THIS IS THE WAY
vim.keymap.set("n", "<up>", "<nop>", { silent = true })
vim.keymap.set("n", "<down>", "<nop>", { silent = true })
vim.keymap.set("n", "<left>", "<nop>", { silent = true })
vim.keymap.set("n", "<right>", "<nop>", { silent = true })

-- move lines in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- undotree
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

-- J append line above to my current line
vim.keymap.set("n", "J", "mzJ`z")

-- keep cursor in middle when moving lines
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Copy only available into Neovim
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
-- Copy available in and outside of Neovim
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- replace the highlited word
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- use jk and kj to exit insert mode
keymap.set("i", "jk", "<ESC>")
keymap.set("i", "kj", "<ESC>")

-- copy and paste an keep the current paste buffer ()
vim.keymap.set("x", "<leader>p", [["_dP]])

-- clear search highlights
vim.keymap.set("n", "<leader>nh", ":nohl<CR>")
-- delete single character without copying into register
vim.keymap.set("n", "x", '"_x')

-- increment/decrement numbers
vim.keymap.set("n", "<leader>+", "<C-a>") -- increment
vim.keymap.set("n", "<leader>-", "<C-x>") -- decrement

-- window management
vim.keymap.set("n", "<leader>sv", "<C-w>v") -- split window vertically
vim.keymap.set("n", "<leader>sh", "<C-w>s") -- split window horizontally
vim.keymap.set("n", "<leader>cn", "<C-w>n") -- split window horizontally
vim.keymap.set("n", "<leader>se", "<C-w>=") -- make split windows equal width & height
vim.keymap.set("n", "<leader>so", "<C-w>o") -- close all windows except current
vim.keymap.set("n", "<leader>st", ":split term://zsh<CR>") -- open terminal in split window
vim.keymap.set("n", "<leader>ss", ":vsplit term://zsh<CR>") -- open terminal in split window
vim.keymap.set("n", "<leader>svb", ":vnew<CR>") -- split window vertically in a new buffer
vim.keymap.set("n", "<leader>sx", ":close<CR>") -- close current split window

-- tab management
vim.keymap.set("n", "<leader>to", ":tabnew<CR>") -- open new tab
vim.keymap.set("n", "<leader>tx", ":tabclose<CR>") -- close current tab
vim.keymap.set("n", "<leader>tn", ":tabn<CR>") --  go to next tab
vim.keymap.set("n", "<leader>tp", ":tabp<CR>") --  go to previous tab

-- new file
vim.keymap.set("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New File" })

-- buffer management

-- Save and quit file
vim.api.nvim_set_keymap("n", "QQ", ":q!<enter>", { noremap = false })
vim.api.nvim_set_keymap("n", "WW", ":w!<enter>", { noremap = false })
----------------------
-- Plugin Keybinds
----------------------
-- Linting & formatting
vim.cmd([[ command! Format execute 'lua vim.lsp.buf.format({async=true})']])
vim.keymap.set("n", "<leader>f", ":Format<cr>")

-- vim-maximizer
vim.keymap.set("n", "<leader>sm", ":MaximizerToggle<CR>") -- toggle split window maximization

-- nvim-tree
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>") -- toggle file explorer
vim.keymap.set("n", "<leader>b", ":NvimTreeFocus<CR>") -- toggle file explorer

-- Git & Fugitive & diffview
vim.keymap.set("n", "<leader>gg", ":Git<CR>")
vim.keymap.set("n", "<leader>gl", ":Git log<CR>")
vim.keymap.set("n", "<leader>gb", ":Git blame<CR>")
vim.keymap.set("n", "<leader>gd", ":Gvdiff<CR>")
vim.api.nvim_set_keymap("n", "<leader>gc", ':Git commit -m "', { noremap = false })
vim.api.nvim_set_keymap("n", "<leader>gp", ":Git push -u origin HEAD<CR>", { noremap = false })

-- bufferline
vim.keymap.set("n", "<leader>1", '<cmd>lua require("bufferline").go_to_buffer(1)<CR>')
vim.keymap.set("n", "<leader>2", '<cmd>lua require("bufferline").go_to_buffer(2)<CR>')
vim.keymap.set("n", "<leader>3", '<cmd>lua require("bufferline").go_to_buffer(3)<CR>')
vim.keymap.set("n", "<leader>4", '<cmd>lua require("bufferline").go_to_buffer(4)<CR>')
vim.keymap.set("n", "<leader>5", '<cmd>lua require("bufferline").go_to_buffer(5)<CR>')
vim.keymap.set("n", "<leader>6", '<cmd>lua require("bufferline").go_to_buffer(6)<CR>')
vim.keymap.set("n", "<leader>7", '<cmd>lua require("bufferline").go_to_buffer(7)<CR>')
vim.keymap.set("n", "<C-n>", ":bnext<CR>")
vim.keymap.set("n", "<C-p>", ":bprev<CR>")
vim.keymap.set("n", "<C-x>", ":bd<CR>")
vim.api.nvim_set_keymap("n", "<C-h>", ":bfirst<enter>", { noremap = false })
vim.api.nvim_set_keymap("n", "<C-l>", ":blast<enter>", { noremap = false })
