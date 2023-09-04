return {
  "lewis6991/gitsigns.nvim",
  opts = {
    signs = {
      add = {
        text = '+',
        hl = "GitSignsAdd",
        numhl = "GitSignsAddNr",
        linehl = "GitSignsAddLn",
      },
      change = {
        text = '~',
        hl = "GitSignsChange",
        numhl = "GitSignsChangeNr",
        linehl = "GitSignsChangeLn",
      },
      delete = {
        text = '_',
        hl = "GitSignsDelete",
        numhl = "GitSignsDeleteNr",
        linehl = "GitSignsDeleteLn",
      },
      topdelete = {
        text = '‾',
        hl = "GitSignsDelete",
        numhl = "GitSignsDeleteNr",
        linehl = "GitSignsDeleteLn",
      },
      changedelete = {
        text = '~',
        hl = "GitSignsChange",
        numhl = "GitSignsChangeNr",
        linehl = "GitSignsChangeLn",
      },
    },
  },
}
