-- Compile config files without loading user config, plugins, or remote hosts.
local files = vim.fn.glob("home/.config/nvim/**/*.lua", true, true)
assert(#files > 0, "Run from the repository root")
for _, file in ipairs(files) do
  local chunk, err = loadfile(file)
  assert(chunk, err)
end
print(("PASS: compiled %d Neovim config files"):format(#files))
