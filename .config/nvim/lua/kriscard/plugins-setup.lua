local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer() -- true if packer was just installed

-- Autocommand that reloads neovim whenever you save this file
-- when file is saved
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])


local status, packer = pcall(require, "packer")
if not status then
  return
end

return packer.startup(function(use)
  use 'wbthomason/packer.nvim'
  use 'nvim-lua/plenary.nvim' -- lua functions that many plugins use

  -- My plugins here
  -- colorscheme
  use { "catppuccin/nvim", as = "catppuccin" }
  -- tmux & split window navigation
  use 'christoomey/vim-tmux-navigator'

  -- maximizes and restores current window
  use 'szw/vim-maximizer'

  -- essential plugins
  use 'tpope/vim-surround'               -- add, delete, change surroundings (it's awesome)
  use 'inkarkat/vim-ReplaceWithRegister' -- replace with register contents using motion (gr + motion)
  -- set leader key to space
  -- file explorer
  use 'nvim-tree/nvim-tree.lua'

  -- commenting with gc
  use 'numToStr/Comment.nvim'

  -- vs-code like icons
  use 'nvim-tree/nvim-web-devicons'

  -- statusline
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }

  -- fuzzy finding w/ telescope
  use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" }) -- dependency for better sorting performance
  use({ "nvim-telescope/telescope.nvim", branch = "0.1.x" })        -- fuzzy finder

  use {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v1.x',
    requires = {
      -- LSP Support
      { 'neovim/nvim-lspconfig' },             -- Required
      { 'williamboman/mason.nvim' },           -- Optional
      { 'williamboman/mason-lspconfig.nvim' }, -- Optional

      -- Autocompletion
      { 'hrsh7th/nvim-cmp' },         -- Required
      { 'hrsh7th/cmp-nvim-lsp' },     -- Required
      { 'hrsh7th/cmp-buffer' },       -- Optional
      { 'hrsh7th/cmp-path' },         -- Optional
      { 'saadparwaiz1/cmp_luasnip' }, -- Optional
      { 'hrsh7th/cmp-nvim-lua' },     -- Optional

      -- Snippets
      { 'L3MON4D3/LuaSnip' },             -- Required
      { 'rafamadriz/friendly-snippets' }, -- Optional
    }
  }


  -- formatting & linting
  use 'jose-elias-alvarez/null-ls.nvim' -- configure formatters & linters
  use 'jayp0521/mason-null-ls.nvim'     -- bridges gap b/w mason & null-ls

  -- auto closing
  use 'windwp/nvim-autopairs'                                  -- autoclose parens, brackets, quotes, etc...
  use({ "windwp/nvim-ts-autotag", after = "nvim-treesitter" }) -- autoclose tags

  -- treesitter configuration
  use({ "nvim-treesitter/nvim-treesitter", run = ':TSUpdate' })

  -- git integration
  use 'lewis6991/gitsigns.nvim'

  use 'mbbill/undotree' -- visualizes the undo history

  -- Dashboard
  use 'goolord/alpha-nvim'

  --Projects
  use "ahmedkhalf/project.nvim"

  --autosave
  use {
    'rmagatti/auto-session',
    config = function()
      require("auto-session").setup {
        log_level = "error",
        auto_session_suppress_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
      }
    end
  }

  -- colorizer for HEX CSS
  use 'norcalli/nvim-colorizer.lua'

  -- diff view
  use { 'sindrets/diffview.nvim', requires = 'nvim-lua/plenary.nvim' }

  --nvim-lsp progress
  use 'j-hui/fidget.nvim'

  -- Github Copilot
  use 'github/copilot.vim'

  --neogit
  use { 'TimUntersberger/neogit', requires = 'nvim-lua/plenary.nvim' }

  -- Todo Comments
  use {
    "folke/todo-comments.nvim",
    requires = "nvim-lua/plenary.nvim",
    config = function()
      require("todo-comments").setup {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      }
    end
  }

  -- blankline
  use "lukas-reineke/indent-blankline.nvim"

  -- nvim lint
  use 'mfussenegger/nvim-lint'

  --float terminal
  use 'numToStr/FTerm.nvim'

  -- tabline plugin
  use { 'akinsho/bufferline.nvim', tag = "v3.*", requires = 'nvim-tree/nvim-web-devicons' }

  -- git-conflict
  use 'akinsho/git-conflict.nvim'

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)
