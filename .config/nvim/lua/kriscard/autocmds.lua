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
local markdown_grp = api.nvim_create_augroup("MarkdownSettings", { clear = true })

-- Enable spell checking and line wrapping for markdown files
api.nvim_create_autocmd("FileType", {
	group = markdown_grp,
	pattern = { "markdown", "mdx", "text", "gitcommit" },
	callback = function()
		vim.opt_local.wrap = true -- Enable line wrapping
		vim.opt_local.linebreak = true -- Break at word boundaries
		vim.opt_local.spell = true -- Enable spell checking
		vim.opt_local.spelllang = "en_us" -- Set spell language
		vim.opt_local.textwidth = 80 -- Wrap at 80 characters
		vim.opt_local.colorcolumn = "" -- Disable color column in markdown
	end,
	desc = "Enable spell check and wrap for markdown files",
})

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

-- Set conceal level for markdown files (for wiki links, etc.)
api.nvim_create_autocmd("FileType", {
	group = markdown_grp,
	pattern = { "markdown" },
	callback = function()
		vim.opt_local.conceallevel = 2
	end,
	desc = "Set conceallevel for markdown",
})
