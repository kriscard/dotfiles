-- set colorscheme to tokyonight with protected call
-- in case it isn't installed
local status, _ = pcall(vim.cmd, 'colorscheme catppuccin')
if not status then
	print("Colorscheme not found!")
  return
end
