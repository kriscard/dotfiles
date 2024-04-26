return {
  "nvim-pack/nvim-spectre",
  build = false,
  cmd = "Spectre",
  opts = { open_cmd = "noswapfile vnew" },
  -- stylua: ignore
  keys = {
    { "<leader>sr", function() require("spectre").open() end,                              desc = "Replace in files (Spectre)" },
    { "<leader>sx", function() require("spectre").close() end,                             desc = "Close Spectre" },

    -- Open Spectre for global find/replace for the word under the cursor in visual mode
    { "<leader>sw", function() require("spectre").open_visual({ select_word = true }) end, desc = "Search current word" }

  },
  config = function()
    local theme = require("catppuccin.palettes").get_palette("macchiato")

    vim.api.nvim_set_hl(0, "SpectreSearch", { bg = theme.red, fg = theme.base })
    vim.api.nvim_set_hl(0, "SpectreReplace", { bg = theme.green, fg = theme.base })

    require("spectre").setup({
      highlight = {
        search = "SpectreSearch",
        replace = "SpectreReplace",
      },
      mapping = {
        ["send_to_qf"] = {
          map = "<C-q>",
          cmd = "<cmd>lua require('spectre.actions').send_to_qf()<CR>",
          desc = "send all items to quickfix",
        },
      },
    })
  end,
}
