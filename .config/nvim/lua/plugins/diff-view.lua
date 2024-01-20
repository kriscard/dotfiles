return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
  opts = {},
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "DiffView" },
    { "<leader>gx", "<cmd>DiffviewClose<cr>", desc = "DiffView" },
  },
}
