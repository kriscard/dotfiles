local api = vim.api

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- don't auto comment new line
api.nvim_create_autocmd("BufEnter", { command = [[set formatoptions-=cro]] })

-- go to last loc when opening a buffer
-- this mean that when you open a file, you will be at the last position
api.nvim_create_autocmd("BufReadPost", {
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- auto close brackets
-- this
api.nvim_create_autocmd("FileType", { pattern = "man", command = [[nnoremap <buffer><silent> q :quit<CR>]] })

-- show cursor line only in active window
local cursorGrp = api.nvim_create_augroup("CursorLine", { clear = true })
api.nvim_create_autocmd({ "InsertLeave", "WinEnter" }, {
	pattern = "*",
	command = "set cursorline",
	group = cursorGrp,
})
api.nvim_create_autocmd(
	{ "InsertEnter", "WinLeave" },
	{ pattern = "*", command = "set nocursorline", group = cursorGrp }
)

-- format on save
api.nvim_create_autocmd("BufWritePre", {
	group = vim.api.nvim_create_augroup("format_on_save", { clear = true }),
	pattern = "*",
	desc = "Run LSP formatting on a file on save",
	callback = function()
		if vim.fn.exists(":Format") > 0 then
			vim.cmd.Format()
		end
	end,
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
