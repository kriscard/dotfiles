vim.o.termguicolors = true

require("catppuccin").setup({
  flavour = "macchiato",
  transparent_background = false,
})
-- setup must be called before loading
vim.cmd.colorscheme "catppuccin"
