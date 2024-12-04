vim.g.autoformat = true -- Enable auto format
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

opt.ignorecase = true -- Ignore case
opt.smartcase = true -- Don't ignore case with capitals

opt.updatetime = 250 -- Save changes to swap file every 200ms and trigger CursorHold

opt.completeopt = "menu,menuone,noselect" -- Customize completion menu behavior

opt.undofile = true -- Enable persistent undo history

opt.termguicolors = true -- True color support

opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time

-- opt.clipboard = "unnamed,unnamedplus" -- Sync with system clipboard

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

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
	opt.clipboard = "unnamedplus"
end)

opt.breakindent = true -- Enable break indent

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Preview substitutions live, as you type!
opt.inccommand = "split"
