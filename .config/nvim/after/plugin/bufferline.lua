local macchiato = require("catppuccin.palettes").get_palette "macchiato"

local present, bufferline = pcall(require, "bufferline")
if not present then
  return
end

bufferline.setup {
  options = {
    buffer_close_icon = "",
    close_icon = "",
    offsets = {
      {
        filetype = "NvimTree",
        text = "Nvim tree",
        highlight = "FileExplorer"
      }
    },
    separator_style = "slant"
  },
  highlights = require("catppuccin.groups.integrations.bufferline").get {
    custom = {
      all = {
        fill = { bg = macchiato.background },
        tab_selected = {
          fg = macchiato.text,
          bg = macchiato.background
        },
        background = {
          fg = macchiato.text,
          bg = macchiato.background
        },
        tab = {
          fg = macchiato.text,
          bg = macchiato.background
        },
      },
      macchiato = {
        background = { fg = macchiato.text },
      },
      latte = {
        background = { fg = macchiato.background },
      },
    },
  },
}
