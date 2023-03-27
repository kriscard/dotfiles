local status, nvimlint = pcall(require, "nvim-lint")
if not status then
  return
end

nvimlint.setup({
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      javascript = { "eslint_d" },
      javascriptreact = { "eslint_d" },
      typescript = { "eslint_d" },
      typescriptreact = { "eslint_d" },
      yaml = { "yamllint" },
    }

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "BufRead" }, {
      callback = function()
        require("lint").try_lint()
      end,
    })
  end
})
