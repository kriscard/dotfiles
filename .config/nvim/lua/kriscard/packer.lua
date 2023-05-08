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
      { 'hrsh7th/nvim-cmp' },             -- Required
      { 'hrsh7th/cmp-nvim-lsp' },         -- Required
      { 'hrsh7th/cmp-buffer' },           -- Optional
      { 'hrsh7th/cmp-path' },             -- Optional
      { 'saadparwaiz1/cmp_luasnip' },     -- Optional
      { 'hrsh7th/cmp-nvim-lua' },         -- Optional
      -- Snippets
      { 'L3MON4D3/LuaSnip' },             -- Required
      { 'rafamadriz/friendly-snippets' }, -- Optional
    }
  }

  -- lspkind for icons as vscode in lsp
  use 'onsails/lspkind.nvim'

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
  use 'tpope/vim-fugitive'

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

  --nvim-lsp progress
  use 'j-hui/fidget.nvim'

  -- Github Copilot
  use 'github/copilot.vim'

  -- Todo Comments
  use {
    "folke/todo-comments.nvim",
    requires = "nvim-lua/plenary.nvim",
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

  -- lsp saga
  use({
    "glepnir/lspsaga.nvim",
    opt = true,
    branch = "main",
    event = "LspAttach",
    -- config = function()
    --   require("lspsaga").setup({})
    -- end,
    requires = {
      { "nvim-tree/nvim-web-devicons" },
      --Please make sure you install markdown and markdown_inline parser
      { "nvim-treesitter/nvim-treesitter" }
    }
  })
end)
