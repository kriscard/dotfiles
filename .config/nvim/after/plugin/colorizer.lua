local present, colorizer = pcall(require, "colorizer")
if not present then
  return
end

colorizer.setup({
  'css',
  'javascript',
  'lua',
  'json',
  'svelte',
})
