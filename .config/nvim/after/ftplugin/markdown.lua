-- Markdown filetype settings
-- These are applied automatically when opening markdown files

local opt = vim.opt_local

-- Text display
opt.wrap = true -- Enable line wrapping for prose
opt.linebreak = true -- Break at word boundaries, not mid-word
opt.textwidth = 80 -- Soft wrap guide
opt.colorcolumn = "" -- Disable color column (not useful for prose)

-- Spell checking
opt.spell = true
opt.spelllang = "en_us"

-- Concealment (for wiki links, formatting marks)
opt.conceallevel = 2

-- Navigation keymaps (buffer-local)
local map = vim.keymap.set
local opts = { buffer = true, silent = true }

-- Jump between headings
map("n", "]h", function()
	vim.fn.search("^##\\+\\s", "W")
end, vim.tbl_extend("force", opts, { desc = "Next heading" }))

map("n", "[h", function()
	vim.fn.search("^##\\+\\s", "bW")
end, vim.tbl_extend("force", opts, { desc = "Previous heading" }))

-- Jump between code blocks
map("n", "]c", function()
	vim.fn.search("^```", "W")
end, vim.tbl_extend("force", opts, { desc = "Next code block" }))

map("n", "[c", function()
	vim.fn.search("^```", "bW")
end, vim.tbl_extend("force", opts, { desc = "Previous code block" }))

-- Jump between list items
map("n", "]l", function()
	vim.fn.search("^\\s*[-*+]\\s\\|^\\s*\\d\\+\\.\\s", "W")
end, vim.tbl_extend("force", opts, { desc = "Next list item" }))

map("n", "[l", function()
	vim.fn.search("^\\s*[-*+]\\s\\|^\\s*\\d\\+\\.\\s", "bW")
end, vim.tbl_extend("force", opts, { desc = "Previous list item" }))

-- Jump between links
map("n", "]k", function()
	vim.fn.search("\\[\\[\\|\\[.*\\](", "W")
end, vim.tbl_extend("force", opts, { desc = "Next link" }))

map("n", "[k", function()
	vim.fn.search("\\[\\[\\|\\[.*\\](", "bW")
end, vim.tbl_extend("force", opts, { desc = "Previous link" }))

-- ══════════════════════════════════════════════════════════════════════════════
-- Text Objects (work with d, c, y, v operators)
-- ══════════════════════════════════════════════════════════════════════════════

-- Select inside code block (between ``` markers)
local function select_inside_codeblock()
	local start_line = vim.fn.search("^```", "bnW")
	local end_line = vim.fn.search("^```", "nW")
	if start_line > 0 and end_line > 0 and end_line > start_line then
		vim.cmd("normal! " .. (start_line + 1) .. "GV" .. (end_line - 1) .. "G")
	end
end

-- Select around code block (including ``` markers)
local function select_around_codeblock()
	local start_line = vim.fn.search("^```", "bnW")
	local end_line = vim.fn.search("^```", "nW")
	if start_line > 0 and end_line > 0 and end_line > start_line then
		vim.cmd("normal! " .. start_line .. "GV" .. end_line .. "G")
	end
end

-- Select inside heading section (from heading to next heading or EOF)
local function select_inside_heading()
	local current = vim.fn.line(".")
	-- Find current heading (search backward)
	local start_line = vim.fn.search("^#\\+\\s", "bnW")
	if start_line == 0 then
		return
	end
	-- Find next heading or use end of file
	vim.fn.cursor(start_line + 1, 1)
	local end_line = vim.fn.search("^#\\+\\s", "nW")
	if end_line == 0 then
		end_line = vim.fn.line("$")
	else
		end_line = end_line - 1
	end
	-- Skip the heading line itself for "inside"
	vim.cmd("normal! " .. (start_line + 1) .. "GV" .. end_line .. "G")
end

-- Select around heading section (including heading line)
local function select_around_heading()
	local start_line = vim.fn.search("^#\\+\\s", "bnW")
	if start_line == 0 then
		return
	end
	vim.fn.cursor(start_line + 1, 1)
	local end_line = vim.fn.search("^#\\+\\s", "nW")
	if end_line == 0 then
		end_line = vim.fn.line("$")
	else
		end_line = end_line - 1
	end
	vim.cmd("normal! " .. start_line .. "GV" .. end_line .. "G")
end

-- Select inside blockquote
local function select_inside_blockquote()
	local current = vim.fn.line(".")
	local start_line = current
	local end_line = current
	-- Find start of blockquote
	while start_line > 1 and vim.fn.getline(start_line - 1):match("^>") do
		start_line = start_line - 1
	end
	-- Find end of blockquote
	while end_line < vim.fn.line("$") and vim.fn.getline(end_line + 1):match("^>") do
		end_line = end_line + 1
	end
	if vim.fn.getline(start_line):match("^>") then
		vim.cmd("normal! " .. start_line .. "GV" .. end_line .. "G")
	end
end

-- Register text objects for operator-pending and visual modes
-- These override treesitter @class in markdown (where classes don't exist)

-- Code block: ic/ac
map({ "o", "x" }, "ic", select_inside_codeblock, vim.tbl_extend("force", opts, { desc = "inside code block" }))
map({ "o", "x" }, "ac", select_around_codeblock, vim.tbl_extend("force", opts, { desc = "around code block" }))

-- Heading section: ih/ah (overrides @conditional in markdown context)
map({ "o", "x" }, "ih", select_inside_heading, vim.tbl_extend("force", opts, { desc = "inside heading section" }))
map({ "o", "x" }, "ah", select_around_heading, vim.tbl_extend("force", opts, { desc = "around heading section" }))

-- Blockquote: iq/aq
map({ "o", "x" }, "iq", select_inside_blockquote, vim.tbl_extend("force", opts, { desc = "inside blockquote" }))
map({ "o", "x" }, "aq", select_inside_blockquote, vim.tbl_extend("force", opts, { desc = "around blockquote" }))

-- ══════════════════════════════════════════════════════════════════════════════
-- Formatting with gm prefix (vim-style, like gc for comment)
-- ══════════════════════════════════════════════════════════════════════════════

-- Register with which-key for discoverability
local ok, wk = pcall(require, "which-key")
if ok then
	wk.add({
		{ "gm", group = "Markdown format", icon = "󰍔" },
		{ "]", group = "Next" },
		{ "[", group = "Previous" },
	}, { buffer = 0 })
end

-- Wrap selection in markdown formatting
map("x", "gmb", "c**<C-r>\"**<Esc>", vim.tbl_extend("force", opts, { desc = "Bold selection" }))
map("x", "gmi", "c*<C-r>\"*<Esc>", vim.tbl_extend("force", opts, { desc = "Italic selection" }))
map("x", "gms", "c~~<C-r>\"~~<Esc>", vim.tbl_extend("force", opts, { desc = "Strikethrough selection" }))
map("x", "gmc", "c`<C-r>\"`<Esc>", vim.tbl_extend("force", opts, { desc = "Inline code selection" }))
map("x", "gml", "c[<C-r>\"]()<Esc>hp", vim.tbl_extend("force", opts, { desc = "Link selection" }))

-- Normal mode: format word under cursor
map("n", "gmb", "viWc**<C-r>\"**<Esc>", vim.tbl_extend("force", opts, { desc = "Bold word" }))
map("n", "gmi", "viWc*<C-r>\"*<Esc>", vim.tbl_extend("force", opts, { desc = "Italic word" }))
map("n", "gmc", "viWc`<C-r>\"`<Esc>", vim.tbl_extend("force", opts, { desc = "Code word" }))

-- Checkbox operations
map("n", "gmx", "I- [ ] <Esc>", vim.tbl_extend("force", opts, { desc = "Insert checkbox" }))
map("n", "gmX", "^f]rx", vim.tbl_extend("force", opts, { desc = "Toggle checkbox" }))

-- Help: show all markdown keybindings
map("n", "gm?", function()
	local help = [[
󰍔 Markdown Keybindings
══════════════════════════════════════

 Formatting (gm prefix)
  gmb  Bold word/selection
  gmi  Italic word/selection
  gms  Strikethrough (visual)
  gmc  Code word/selection
  gml  Link (visual)
  gmx  Insert checkbox
  gmX  Toggle checkbox

 Navigation
  ]h / [h  Next/prev heading
  ]c / [c  Next/prev code block
  ]l / [l  Next/prev list item
  ]k / [k  Next/prev link

 Text Objects
  ic / ac  Inside/around code block
  ih / ah  Inside/around heading
  iq / aq  Inside/around blockquote

 Preview
  <leader>mp  Toggle browser preview
  <leader>um  Toggle render-markdown
]]
	-- Use Snacks floating window if available
	local snacks_ok, Snacks = pcall(require, "snacks")
	if snacks_ok then
		Snacks.win({
			text = help,
			width = 44,
			height = 28,
			border = "rounded",
			title = " Markdown Help ",
			title_pos = "center",
			ft = "markdown",
		})
	else
		-- Fallback to vim.notify
		vim.notify(help, vim.log.levels.INFO)
	end
end, vim.tbl_extend("force", opts, { desc = "Markdown keybindings help" }))
