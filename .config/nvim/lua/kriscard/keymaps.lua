local Util = require("kriscard.util")

local map = Util.safe_keymap_set

-- ══════════════════════════════════════════════════════════════════════════════
-- BASIC KEYMAPS
-- ══════════════════════════════════════════════════════════════════════════════

-- Disable Space bar since it'll be used as the leader key
map("n", "<space>", "<nop>")

-- Save file
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- Quit
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

-- ══════════════════════════════════════════════════════════════════════════════
-- BUFFER NAVIGATION
-- ══════════════════════════════════════════════════════════════════════════════

-- Buffer navigation
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<C-x>", ":bd<CR>", { desc = "Close current buffer" })

-- ══════════════════════════════════════════════════════════════════════════════
-- MOVEMENT & NAVIGATION
-- ══════════════════════════════════════════════════════════════════════════════

-- Move lines in visual mode
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move lines down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move lines up" })

-- Center buffer while navigating
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
map("n", "{", "{zz", { desc = "Previous paragraph (centered)" })
map("n", "}", "}zz", { desc = "Next paragraph (centered)" })
map("n", "N", "Nzz", { desc = "Previous search (centered)" })
map("n", "n", "nzz", { desc = "Next search (centered)" })
map("n", "G", "Gzz", { desc = "Go to end (centered)" })
map("n", "gg", "ggzz", { desc = "Go to start (centered)" })
map("n", "<C-i>", "<C-i>zz", { desc = "Jump forward (centered)" })
map("n", "<C-o>", "<C-o>zz", { desc = "Jump backward (centered)" })
map("n", "%", "%zz", { desc = "Match bracket (centered)" })
map("n", "*", "*zz", { desc = "Search word forward (centered)" })
map("n", "#", "#zz", { desc = "Search word backward (centered)" })

-- Exit terminal mode
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- ══════════════════════════════════════════════════════════════════════════════
-- SEARCH & REPLACE
-- ══════════════════════════════════════════════════════════════════════════════

-- Clear search highlights
map("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- Replace the highlighted word
map("n", "<leader>S", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace highlighted word" })

-- ══════════════════════════════════════════════════════════════════════════════
-- LSP & DIAGNOSTICS (Global mappings)
-- ══════════════════════════════════════════════════════════════════════════════

-- Diagnostic navigation (global)
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

map("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
map("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
map("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
map("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })

-- Diagnostic lists
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Code actions (can work globally)
map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })

-- ══════════════════════════════════════════════════════════════════════════════
-- CORE LSP NAVIGATION (Global - work across all buffers)
-- ══════════════════════════════════════════════════════════════════════════════

-- Definition and navigation
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
map("n", "gr", vim.lsp.buf.references, { desc = "Go to references" })
map("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
map("n", "gt", vim.lsp.buf.type_definition, { desc = "Go to type definition" })

-- Documentation
map("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })
map("n", "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature help" })

-- Renaming
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "[R]e[n]ame" })

-- ══════════════════════════════════════════════════════════════════════════════
-- PLUGIN MANAGERS & TOOLS
-- ══════════════════════════════════════════════════════════════════════════════

-- Lazy package manager
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- Mason LSP installer
map("n", "<leader>cm", "<cmd>Mason<cr>", { desc = "Mason" })

-- ══════════════════════════════════════════════════════════════════════════════
-- FILE MANAGEMENT
-- ══════════════════════════════════════════════════════════════════════════════

-- Oil file explorer (changed from <leader>e to avoid conflict with diagnostics)
map("n", "<leader>fe", function()
	require("oil").toggle_float()
end, { desc = "[F]ile [E]xplorer (Oil)" })

-- Alternative oil mapping
map("n", "<leader>-", function()
	require("oil").toggle_float()
end, { desc = "Open Oil" })

-- ══════════════════════════════════════════════════════════════════════════════
-- GIT INTEGRATION
-- ══════════════════════════════════════════════════════════════════════════════

-- LazyGit
map("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "Lazygit (Root Dir)" })

-- ══════════════════════════════════════════════════════════════════════════════
-- WINDOW MANAGEMENT
-- ══════════════════════════════════════════════════════════════════════════════

map("n", "<leader>wd", "<C-W>c", { desc = "Delete window", remap = true })
map("n", "<leader>w-", "<C-W>s", { desc = "Split window below", remap = true })
map("n", "<leader>w|", "<C-W>v", { desc = "Split window right", remap = true })

-- Additional window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Window resizing
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- ══════════════════════════════════════════════════════════════════════════════
-- OBSIDIAN NOTES (using new command format)
-- ══════════════════════════════════════════════════════════════════════════════
-- Note: Avoid keymap prefix conflicts (e.g., <leader>ot vs <leader>otg)

map("n", "<leader>oo", "<cmd>Obsidian open<cr>", { desc = "Open in Obsidian app" })
map("n", "<leader>on", "<cmd>Obsidian new<cr>", { desc = "New note" })
map("n", "<leader>oq", "<cmd>Obsidian quick_switch<cr>", { desc = "Quick switch" })
map("n", "<leader>od", "<cmd>Obsidian today<cr>", { desc = "Daily note (today)" })
map("n", "<leader>oy", "<cmd>Obsidian yesterday<cr>", { desc = "Yesterday's note" })
map("n", "<leader>oD", "<cmd>Obsidian tomorrow<cr>", { desc = "Tomorrow's note" })
map("n", "<leader>oi", "<cmd>Obsidian template<cr>", { desc = "Insert template" })
map("n", "<leader>ob", "<cmd>Obsidian backlinks<cr>", { desc = "Backlinks" })
map("n", "<leader>ol", "<cmd>Obsidian links<cr>", { desc = "Links in note" })
map("n", "<leader>oc", "<cmd>Obsidian toc<cr>", { desc = "Table of contents" })
map("n", "<leader>op", "<cmd>Obsidian paste_img<cr>", { desc = "Paste image" })
map("n", "<leader>os", "<cmd>Obsidian search<cr>", { desc = "Search notes" })
map("n", "<leader>or", "<cmd>Obsidian rename<cr>", { desc = "Rename note" })
map("n", "<leader>of", "<cmd>Obsidian follow_link<cr>", { desc = "Follow link" })
map("n", "<leader>ot", "<cmd>Obsidian tags<cr>", { desc = "Search tags" })
-- Visual mode mappings
map("v", "<leader>oL", "<cmd>Obsidian link<cr>", { desc = "Link to existing note" })
map("v", "<leader>oN", "<cmd>Obsidian link_new<cr>", { desc = "Link to new note" })
map("v", "<leader>oe", "<cmd>Obsidian extract_note<cr>", { desc = "Extract to note" })

-- ══════════════════════════════════════════════════════════════════════════════
-- EDUCATIONAL / HELPFUL REMINDERS
-- ══════════════════════════════════════════════════════════════════════════════

-- Disable arrow keys in normal mode (encourage hjkl usage)
map("n", "<left>", '<cmd>echo "Use h to move!!"<CR>', { desc = "Disabled - use h" })
map("n", "<right>", '<cmd>echo "Use l to move!!"<CR>', { desc = "Disabled - use l" })
map("n", "<up>", '<cmd>echo "Use k to move!!"<CR>', { desc = "Disabled - use k" })
map("n", "<down>", '<cmd>echo "Use j to move!!"<CR>', { desc = "Disabled - use j" })

-- ══════════════════════════════════════════════════════════════════════════════
-- REACT DEVELOPMENT SPECIFIC
-- ══════════════════════════════════════════════════════════════════════════════

-- Quick React patterns (these work globally)
map("n", "<leader>rc", "o{/* */}<Esc>hhi", { desc = "[R]eact [C]omment" })
map("n", "<leader>rl", "oconsole.log()<Esc>hi", { desc = "[R]eact [L]og" })

-- ══════════════════════════════════════════════════════════════════════════════
-- ADDITIONAL USEFUL MAPPINGS
-- ══════════════════════════════════════════════════════════════════════════════

-- Better indenting
map("v", "<", "<gv", { desc = "Indent left and reselect" })
map("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Stay in indent mode
map("v", "<Tab>", ">gv", { desc = "Indent right" })
map("v", "<S-Tab>", "<gv", { desc = "Indent left" })

-- Paste without yanking in visual mode
map("v", "p", '"_dP', { desc = "Paste without yanking" })

-- Delete without yanking
map({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without yanking" })

-- Select all
map("n", "<C-a>", "gg<S-v>G", { desc = "Select all" })

-- Better join lines
map("n", "J", "mzJ`z", { desc = "Join lines (keep cursor position)" })

-- Quick fix list navigation
map("n", "<leader>co", "<cmd>copen<cr>", { desc = "Open quickfix list" })
map("n", "<leader>cc", "<cmd>cclose<cr>", { desc = "Close quickfix list" })
map("n", "]q", "<cmd>cnext<cr>", { desc = "Next quickfix item" })
map("n", "[q", "<cmd>cprev<cr>", { desc = "Previous quickfix item" })

-- Location list navigation
map("n", "<leader>lo", "<cmd>lopen<cr>", { desc = "Open location list" })
map("n", "<leader>lc", "<cmd>lclose<cr>", { desc = "Close location list" })
map("n", "]l", "<cmd>lnext<cr>", { desc = "Next location item" })
map("n", "[l", "<cmd>lprev<cr>", { desc = "Previous location item" })
