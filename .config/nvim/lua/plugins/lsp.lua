return {
  {
    "mfussenegger/nvim-lint",
    event = {
      "BufReadPre",
      "BufNewFile",
    },
    config = function()
      local lint = require("lint")

      lint.linters_by_ft = {
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        svelte = { "eslint_d" },
        kotlin = { "ktlint" },
        terraform = { "tflint" },
        erb = { "erb_lint" },
        rubocop = { "rubocop" },
        prisma = { "prisma_lint" },
      }

      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_augroup,
        callback = function()
          lint.try_lint()
        end,
      })

      vim.keymap.set("n", "<leader>ll", function()
        lint.try_lint()
      end, { desc = "Trigger linting for current file" })
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = function()
      ---@class ConformOpts
      local opts = {
        -- LazyVim will use these options when formatting with the conform.nvim formatter
        format = {
          timeout_ms = 3000,
          async = false, -- not recommended to change
          quiet = false, -- not recommended to change
        },
        ---@type table<string, conform.FormatterUnit[]>
        formatters_by_ft = {
          lua = { "stylua" },
          svelte = { { "prettierd", "prettier" } },
          javascript = { { "prettierd", "prettier" } },
          typescript = { { "prettierd", "prettier" } },
          javascriptreact = { { "prettierd", "prettier" } },
          typescriptreact = { { "prettierd", "prettier" } },
          json = { { "prettierd", "prettier" } },
          graphql = { { "prettierd", "prettier" } },
          markdown = { { "prettierd", "prettier" } },
          erb = { "htmlbeautifier" },
          html = { "htmlbeautifier" },
          bash = { "beautysh" },
          rust = { "rustfmt" },
          yaml = { "yamlfix" },
          toml = { "taplo" },
          css = { { "prettierd", "prettier" } },
          scss = { { "prettierd", "prettier" } },
        },
        -- The options you set here will be merged with the builtin formatters.
        -- You can also define any custom formatters here.
        ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
        formatters = {
          injected = { options = { ignore_errors = true } },
        },
      }
      return opts
    end,
  },

  { "prisma/vim-prisma" },
}
