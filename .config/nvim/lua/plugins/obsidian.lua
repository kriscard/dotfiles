return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = false,
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-cmp",
    "telescope.nvim",
  },
  config = function(_, opts)
    -- Setup obsidian.nvim
    require("obsidian").setup(opts)

    -- Create which-key mappings for common commands.
    local wk = require("which-key")

    wk.register({
      ["<leader>o"] = {
        name = "Obsidian",
        o = { "<cmd>ObsidianOpen<cr>", "Open note" },
        n = { "<cmd>ObsidianNew<cr>", "New note" },
        t = { "<cmd>ObsidianTemplate<cr>", "Templates list" },
        b = { "<cmd>ObsidianBacklinks<cr>", "Backlinks" },
        p = { "<cmd>ObsidianPasteImg<cr>", "Paste image" },
        q = { "<cmd>ObsidianQuickSwitch<cr>", "Quick switch" },
        s = { "<cmd>ObsidianSearch<cr>", "Search" },
        ww = { "<cmd>ObsidianWorkspace work<cr>", "Switch workspaces" },
        wc = { "<cmd>ObsidianWorkspace code<cr>", "Switch workspaces" },
      },
    })
  end,
  opts = {
    workspaces = {
      {
        name = "code",
        path = "~/obsidian-vault-code/",
      },
      {
        name = "work",
        path = "~/obsidian-vault-work/",
      },
    },

    finder = "telescope.nvim",

    completion = {
      nvim_cmp = true,
      min_chars = 2,
      prepend_note_path = false,
      prepend_note_id = true,
      use_path_only = false,
      new_notes_location = "current_dir",
    },

    templates = {
      subdir = "Templates",
      date_format = "%Y-%m-%d-%a",
      time_format = "%H:%M",
    },
  },
}
