vim.g.autoformat = true -- Enable auto format
vim.g.mapleader = " " -- Set leader key to space
vim.g.maplocalleader = " " -- Set leader key to space


local opt = vim.opt

opt.relativenumber = true -- Relative line numbers

opt.tabstop = 2 -- Set tabs to 2 spaces
opt.softtabstop = 2 -- Set tabs to 2 spaces
opt.expandtab = true -- Use spaces instead of tabs
opt.smartindent = true -- Insert indents automatically

opt.incsearch = true --Enable incremental searching

opt.wrap = false -- Disable line wrap

opt.splitbelow = true -- Put new windows below current
opt.splitkeep = "screen"
opt.splitright = true -- Put new windows right of current

opt.mouse = "a" -- Enable mouse mode

opt.ignorecase = true -- Ignore case
opt.smartcase = true -- Don't ignore case with capitals

opt.updatetime = 200 -- Save changes to swap file every 200ms and trigger CursorHold

opt.completeopt = "menu,menuone,noselect"  -- Customize completion menu behavior

opt.undofile = true -- Enable persistent undo history

opt.termguicolors = true -- True color support

opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time

opt.clipboard = "unnamed,unnamedplus" -- Sync with system clipboard

opt.cursorline = true -- Enable highlighting of the current line

opt.scrolloff = 8 -- Always keep 8 lines above/below cursor unless at start/end of file

opt.colorcolumn = "80" -- Highlight the 80th column in the window

opt.autowrite = true -- Automatically saves the current buffer when it becomes inactive or certain commands are executed

opt.confirm = true -- Enables confirmation prompts for destructive operations like quitting without saving

opt.formatoptions = "jcroqlnt" -- Configures automatic formatting and text wrapping behavior

opt.grepformat = "%f:%l:%c:%m" -- Format of grep search results (filename:line:column:text)

opt.grepprg = "rg --vimgrep" -- Set the external grep-like search command to use 'ripgrep' with 'vimgrep' formatting

opt.laststatus = 3 -- global statusline

-- Set fold settings
-- These options were reccommended by nvim-ufo
-- See: https://github.com/kevinhwang91/nvim-ufo#minimal-configuration
opt.foldcolumn = "0"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true

