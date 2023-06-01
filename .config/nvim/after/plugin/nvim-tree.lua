local setup, nvimtree = pcall(require, "nvim-tree")
if not setup then
  return
end

-- recommended settings from nvim-tree documentation
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- change color for arrows in tree to light blue
vim.cmd([[ highlight NvimTreeIndentMarker guifg=#3FC5FF ]])

-- nvimtree.setup({
--   filters = {
--     dotfiles = false,
--   },
--   view = {
--     float = {
--       enable = true
--     }
--   }
-- })
nvimtree.setup({
  sync_root_with_cwd = true,
  actions = {
    open_file = {
      resize_window = true,
    },
  },
  view = {
    float = {
      enable = true,
      open_win_config = {
        width = 40
      }
    },
  },
  update_focused_file = {
    enable = true,
    update_cwd = true,
  },
  filters = {
    dotfiles = false,
    custom = { ".git$", ",env$" }
  },
  diagnostics = {
    enable = true,
  },
})
