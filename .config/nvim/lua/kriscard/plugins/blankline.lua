return {
  "lukas-reineke/indent-blankline.nvim",
  config = function()
    local blankline = require("indent_blankline")

    blankline.setup {
      show_end_of_line = true,
    }
  end
}
