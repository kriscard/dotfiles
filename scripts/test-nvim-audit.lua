-- Run with the branch config: see scripts/test-nvim-audit.sh.
for _, host in ipairs({ "node", "python3", "ruby", "perl" }) do
  assert(vim.g["loaded_" .. host .. "_provider"] == 0, host .. " provider should be disabled")
end

-- Headless startup does not emit UIEnter. Exercise the actual UIEnter wiring
-- before deciding whether a UI provider is broken.
vim.api.nvim_exec_autocmds("UIEnter", {})
assert(vim.ui.input == Snacks.input.input, "Snacks should own vim.ui.input after UIEnter")
assert(vim.ui.select == Snacks.picker.select, "Snacks should own vim.ui.select after UIEnter")
require("lazy").load({ plugins = { "nvim-treesitter-textobjects" } })
assert(vim.fn.maparg("]]", "n", false, true).desc == "Next start @class.outer")
assert(vim.fn.maparg("[[", "n", false, true).desc == "Prev start @class.outer")
assert(vim.fn.maparg("]r", "n", false, true).desc == "Next Reference")
assert(vim.fn.maparg("[r", "n", false, true).desc == "Prev Reference")

local markdown = require("plugins.markdown")[1]
for _, ft in ipairs(markdown.ft) do
  assert(ft ~= "Avante" and ft ~= "codecompanion", "stale AI filetype")
end
print("PASS: optional hosts, UIEnter providers, class/reference mappings, markdown filetypes")
