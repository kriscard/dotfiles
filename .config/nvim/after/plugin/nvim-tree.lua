local setup, nvimtree = pcall(require, "nvim-tree")
if not setup then
  return
end

-- recommended settings from nvim-tree documentation
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- change color for arrows in tree to light blue
vim.cmd([[ highlight NvimTreeIndentMarker guifg=#3FC5FF ]])

nvimtree.setup({
  filters = {
    dotfiles = false,
    custom = { '^.git$' },
  },
  view = {
    float = {
      enable = true
    }
  }
})
