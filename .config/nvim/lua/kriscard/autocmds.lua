local api = vim.api

local augroup = api.nvim_create_augroup("kriscard-general", { clear = true })

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = augroup,
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- don't auto comment new line
api.nvim_create_autocmd("BufEnter", {
	group = augroup,
	callback = function()
		vim.opt_local.formatoptions:remove({ "c", "r", "o" })
	end,
})

-- go to last loc when opening a buffer
-- this mean that when you open a file, you will be at the last position
api.nvim_create_autocmd("BufReadPost", {
	group = augroup,
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- Quick quit for man pages
api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = "man",
	callback = function(event)
		vim.keymap.set("n", "q", "<cmd>quit<cr>", { buffer = event.buf, silent = true })
	end,
})

-- show cursor line only in active window
local cursorGrp = api.nvim_create_augroup("CursorLine", { clear = true })
api.nvim_create_autocmd({ "InsertLeave", "WinEnter" }, {
	pattern = "*",
	group = cursorGrp,
	callback = function()
		vim.opt_local.cursorline = true
	end,
})
api.nvim_create_autocmd({ "InsertEnter", "WinLeave" }, {
	pattern = "*",
	group = cursorGrp,
	callback = function()
		vim.opt_local.cursorline = false
	end,
})

-- Close utility buffers with q
api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = { "help", "qf", "lspinfo", "checkhealth", "notify", "startuptime" },
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
	end,
	desc = "Close utility buffers with q",
})

-- Auto-create parent directories on save
api.nvim_create_autocmd("BufWritePre", {
	group = augroup,
	callback = function(event)
		if event.match:match("^%w%w+://") then
			return
		end
		local file = vim.uv.fs_realpath(event.match) or event.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
	desc = "Auto-create parent directories on save",
})

-- Resize splits on VimResized
api.nvim_create_autocmd("VimResized", {
	group = augroup,
	callback = function()
		local current_tab = vim.fn.tabpagenr()
		vim.cmd("tabdo wincmd =")
		vim.cmd("tabnext " .. current_tab)
	end,
	desc = "Resize splits when terminal is resized",
})

-- ══════════════════════════════════════════════════════════════════════════════
-- Markdown & Obsidian specific autocommands
-- ══════════════════════════════════════════════════════════════════════════════
-- Note: Most markdown settings are now in after/ftplugin/markdown.lua
-- Only Obsidian-specific autocmds remain here

local markdown_grp = api.nvim_create_augroup("MarkdownSettings", { clear = true })

-- Auto-save for Obsidian vault files (no confirmation needed)
api.nvim_create_autocmd({ "FocusLost", "BufLeave" }, {
	group = markdown_grp,
	pattern = "*/obsidian-vault-kriscard/*",
	callback = function()
		if vim.bo.modified and vim.bo.buftype == "" then
			vim.cmd("silent! write")
		end
	end,
	desc = "Auto-save Obsidian notes on focus lost",
})

-- Spell and wrap for non-markdown prose files (gitcommit, text)
api.nvim_create_autocmd("FileType", {
	group = markdown_grp,
	pattern = { "text", "gitcommit" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
		vim.opt_local.spell = true
		vim.opt_local.spelllang = "en_us"
	end,
	desc = "Enable spell check and wrap for prose files",
})
