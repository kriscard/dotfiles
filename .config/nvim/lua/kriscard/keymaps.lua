local Util = require("kriscard.util")

local map = Util.safe_keymap_set

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
map("n", "L", "$")
map("n", "H", "^")

-- Press 'H', 'L' to jump to start/end of a line (first/last char)
map("v", "L", "$<left>")
map("v", "H", "^")

-- Git keymaps --
map("n", "<leader>gb", ":Gitsigns toggle_current_line_blame<cr>", { desc = "Toggle Blame" })
