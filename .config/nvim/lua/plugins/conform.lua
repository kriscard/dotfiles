return {
  "stevearc/conform.nvim", -- Format plugin
  lazy = false,
  keys = {
    {
      "<leader>cf",
      '<CMD>lua require("conform").format({ lsp_fallback = true, async = false, timeout_ms = 1000 })<CR>',
      desc = "Format code",
    },
  },
  opts = {
    formatters_by_ft = {
      javascript = { "prettier" },
      typescript = { "prettier" },
      javascriptreact = { "prettier" },
      typescriptreact = { "prettier" },
      svelte = { "prettier" },
      css = { "prettier" },
      html = { "prettier" },
      json = { "prettier" },
      yaml = { "prettier" },
      markdown = { "prettier" },
      mdx = { "prettier" },
      astro = { "prettier" },
      graphql = { "prettier" },
      liquid = { "prettier" },
      lua = { "stylua" },
      python = { "isort", "black" },
      ruby = { "rubocop" },
    },
  },
}
