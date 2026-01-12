vim.g.autoformat = true -- Enable auto format

-- Snacks animations
-- Set to `false` to globally disable all snacks animations
vim.g.snacks_animate = true

-- Show the current document symbols location from Trouble in lualine
-- You can disable this for a buffer by setting `vim.b.trouble_lualine = false`
vim.g.trouble_lualine = true

-- Fix markdown indentation settings
vim.g.markdown_recommended_style = 0

-- Add Mason binaries to PATH for formatters/linters
vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH

local opt = vim.opt

opt.relativenumber = true -- Relative line numbers

opt.tabstop = 2 -- Set tabs to 2 spaces
-- opt.softtabstop = 2 -- Set tabs to 2 spaces
opt.expandtab = true -- Use spaces instead of tabs
opt.autoindent = true -- copy indent from current line when starting new one
opt.shiftwidth = 2 -- 2 spaces for indent width

opt.incsearch = true --Enable incremental searching

opt.wrap = false -- Disable line wrap

opt.list = false -- Show some invisible characters (tabs...)

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

opt.splitbelow = true -- Put new windows below current
opt.splitkeep = "screen"
opt.splitright = true -- Put new windows right of current

opt.mouse = "a" -- Enable mouse mode

opt.updatetime = 250 -- Save changes to swap file every 250ms and trigger CursorHold

opt.completeopt = "menu,menuone,noselect" -- Customize completion menu behavior

opt.undofile = true -- Enable persistent undo history
opt.undolevels = 10000

opt.termguicolors = true -- True color support

opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time

-- opt.clipboard = "unnamed,unnamedplus" -- Sync with system clipboard

-- only set clipboard if not in ssh, to make sure the OSC 52
-- integration works automatically. Requires Neovim >= 0.10.0
opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" -- Sync with system clipboard

opt.cursorline = true -- Enable highlighting of the current line

opt.scrolloff = 10 -- Always keep 8 lines above/below cursor unless at start/end of file

opt.colorcolumn = "80" -- Highlight the 80th column in the window

opt.autowrite = true -- Automatically saves the current buffer when it becomes inactive or certain commands are executed

opt.confirm = true -- Enables confirmation prompts for destructive operations like quitting without saving

opt.formatoptions = "jcroqlnt" -- Configures automatic formatting and text wrapping behavior

opt.grepformat = "%f:%l:%c:%m" -- Format of grep search results (filename:line:column:text)

opt.grepprg = "rg --vimgrep" -- Set the external grep-like search command to use 'ripgrep' with 'vimgrep' formatting

opt.laststatus = 3 -- global statusline

opt.conceallevel = 2 -- Config for Obsidian

-- Set fold settings
-- These options were reccommended by nvim-ufo
-- See: https://github.com/kevinhwang91/nvim-ufo#minimal-configuration
opt.foldcolumn = "0"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true

opt.breakindent = true -- Enable break indent

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
opt.timeoutlen = vim.g.vscode and 1000 or 300 -- Lower than default (1000) to quickly trigger which-key

-- Preview substitutions live, as you type!
opt.inccommand = "split"

opt.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}

opt.jumpoptions = "view"
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.shiftround = true -- Round indent
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.showmode = false -- Dont show mode since we have a statusline
opt.sidescrolloff = 8 -- Columns of context
opt.smartindent = true -- Insert indents automatically
opt.spelllang = { "en" }
opt.statuscolumn = [[%!v:lua.require'snacks.statuscolumn'.get()]]
opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
opt.wildmode = "longest:full,full" -- Command-line completion mode
opt.winminwidth = 5 -- Minimum window width
opt.foldmethod = "indent"
opt.foldtext = "v:lua.require'snacks.fold'.get()"

-- Performance optimizations for large React projects
opt.maxmempattern = 20000 -- Increase memory for pattern matching
opt.regexpengine = 0 -- Use automatic regexp engine selection
opt.synmaxcol = 200 -- Only highlight first 200 columns for performance

-- Better diff performance
opt.diffopt:append("algorithm:patience")
opt.diffopt:append("indent-heuristic")

-- Semantic highlighting (Neovim 0.10+)
-- Ensure LSP semantic tokens take priority over treesitter syntax highlighting
vim.highlight.priorities.semantic_tokens = 95

-- Enhanced diagnostic configuration (Neovim 0.10+)
vim.diagnostic.config({
	virtual_text = {
		spacing = 4,
		prefix = "●",
		source = "if_many", -- Show source only when multiple diagnostics exist
	},
	float = {
		source = "if_many", -- Show source in hover window when multiple diagnostics
		border = "rounded",
		header = "",
		prefix = "",
	},
	signs = true,
	underline = true,
	update_in_insert = false, -- Don't update diagnostics while typing
	severity_sort = true, -- Sort by severity (errors first)
})
