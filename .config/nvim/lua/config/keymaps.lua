-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set

-- Normal --
-- Disable Space bar since it'll be used as the leader key
-- save file
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- quit
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

-- buffers
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })

-- move lines in visual mode
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "moves lines in visual mode" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "moves lines in visual mode" })

-- replace the highlited word
map("n", "<leader>S", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "replace the highlited word" })

-- clear search highlights
map("n", "<leader>nh", ":nohl<CR>", { desc = "clear search highlights" })

-- close current buffer
map("n", "<C-x>", ":bd<CR>", { desc = "Close current buffer" })

-- lazy
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- code actions
map({ "n", "v" }, "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<cr>", { desc = "Code action" })

-- Mason
map("n", "<leader>cm", "<cmd>Mason<cr>", { desc = "Mason" })

-- diagnostic
local diagnostic_goto = function(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    go({ severity = severity })
  end
end
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
map("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
map("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
map("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })

--get all diagnostics using telescope
map("n", "<leader>sd", require("telescope.builtin").diagnostics, { desc = "[S]earch [D]iagnostics" })
-- map("n", "<leader>sd", require("telescope.builtin").git_files, { desc = "[S]earch [D]iagnostics" })

-- lazygit
map("n", "<leader>gg", "<cmd>LazyGit<cr>", { noremap = true })

-- windows
map("n", "<leader>wd", "<C-W>c", { desc = "Delete window", remap = true })
map("n", "<leader>w-", "<C-W>s", { desc = "Split window below", remap = true })
map("n", "<leader>w|", "<C-W>v", { desc = "Split window right", remap = true })

-- oil
-- Map Oil to <leader>e
map("n", "<leader>e", function()
  require("oil").toggle_float()
end, { desc = "Open Oil" })

-- Center buffer while navigating
map("n", "<C-u>", "<C-u>zz")
map("n", "<C-d>", "<C-d>zz")
map("n", "{", "{zz")
map("n", "}", "}zz")
map("n", "N", "Nzz")
map("n", "n", "nzz")
map("n", "G", "Gzz")
map("n", "gg", "ggzz")
map("n", "<C-i>", "<C-i>zz")
map("n", "<C-o>", "<C-o>zz")
map("n", "%", "%zz")
map("n", "*", "*zz")
map("n", "#", "#zz")

-- Press 'H', 'L' to jump to start/end of a line (first/last char)
map("v", "L", "$<left>")
map("v", "H", "^")

-- Toggle relative line numbers
map("n", "<leader>nn", ":set rnu<CR>", { noremap = true, silent = true, desc = "Turn on relative number" })
map("n", "<leader>nx", ":set nornu<CR>", { noremap = true, silent = true, desc = "Turn off relative number" })

-- reload lsp server
map("n", "<leader>clr", "<cmd>LspRestart<cr>", { desc = "Reload LSP server" })
