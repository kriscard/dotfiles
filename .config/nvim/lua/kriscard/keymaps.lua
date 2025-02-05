local Util = require("kriscard.util")

local map = Util.safe_keymap_set

-- Normal --
-- Disable Space bar since it'll be used as the leader key
-- save file
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- quit
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

-- buffers
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })

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
		go({
			severity = severity,
			float = {
				source = true,
				border = "rounded",
			},
		})
	end
end
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
map("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
map("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
map("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })
--
-- lazygit
map("n", "<leader>gg", "<cmd>LazyGit<cr>", { noremap = true, desc = "Lazygit (Root Dir)" })

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
-- map("v", "L", "$<left>")
-- map("v", "H", "^")

-- Diagnostic keymaps
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- TIP: Disable arrow keys in normal mode
map("n", "<left>", '<cmd>echo "Use h to move!!"<CR>')
map("n", "<right>", '<cmd>echo "Use l to move!!"<CR>')
map("n", "<up>", '<cmd>echo "Use k to move!!"<CR>')
map("n", "<down>", '<cmd>echo "Use j to move!!"<CR>')

-- Obsidian
map("n", "<leader>oo", "<cmd>ObsidianOpen<cr>", { desc = "Open note" })
map("n", "<leader>on", "<cmd>ObsidianNew<cr>", { desc = "New note" })
map("n", "<leader>ot", "<cmd>ObsidianToday<cr>", { desc = "New Daily Note" })
map("n", "<leader>oT", "<cmd>ObsidianTemplate<cr>", { desc = "Templates list" })
map("n", "<leader>ob", "<cmd>ObsidianBacklinks<cr>", { desc = "Backlinks" })
map("n", "<leader>op", "<cmd>ObsidianPasteImg<cr>", { desc = "Paste image" })
map("n", "<leader>os", "<cmd>ObsidianSearch<cr>", { desc = "Search" })
