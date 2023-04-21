require('lint').linters_by_ft = {
  linters_by_ft = {
    javascript = { "eslint" },
    javascriptreact = { "eslint" },
    typescript = { "eslint" },
    typescriptreact = { "eslint" },
    yaml = { "yamllint" },
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "BufRead" }, {
      callback = function()
        require("lint").try_lint()
      end,
    })
  }
}
