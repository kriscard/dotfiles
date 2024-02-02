return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = {
        enabled = true,
      },
      servers = {
        tsserver = {
          init_options = { preferences = { importModuleSpecifierPreference = "non-relative" } },
          settings = {
            javascript = {
              inlayHints = {
                includeInlayFunctionParameterTypeHints = true,
                includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all';
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayVariableTypeHints = true,
              },
            },
            typescript = {
              inlayHints = {
                includeInlayFunctionParameterTypeHints = true,
                includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all';
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayVariableTypeHints = true,
              },
            },
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              hint = {
                enable = true,
              },
            },
          },
        },
        ruff_lsp = {},
      },
      setup = {
        eslint = function()
          require("lazyvim.util").lsp.on_attach(function(client, _)
            if client.name == "tsserver" then
              client.server_capabilities.documentFormattingProvider = false
            end
            if client.name == "eslint" then
              client.server_capabilities.documentFormattingProvider = true
            end
          end)
        end,
        rubocop = function()
          require("lazyvim.util").lsp.on_attach(function(client, _)
            if client.name == "rubocop" then
              client.server_capabilities.documentFormattingProvider = false
            end
          end)
        end,
        solargraph = function()
          require("lazyvim.util").lsp.on_attach(function(client, _)
            if client.name == "solargraph" then
              client.server_capabilities.documentFormattingProvider = false
            end
          end)
        end,
        tailwindcss = function()
          require("lazyvim.util").lsp.on_attach(function(client, _)
            if client.name == "tailwindcss" then
              client.server_capabilities.documentFormattingProvider = false
            end
          end)
        end,
        astro = function()
          require("lazyvim.util").lsp.on_attach(function(client, _)
            if client.name == "astro" then
              client.server_capabilities.documentFormattingProvider = false
            end
          end)
        end,
        html = function()
          require("lazyvim.util").lsp.on_attach(function(client, _)
            if client.name == "html" then
              client.server_capabilities.documentFormattingProvider = false
            end
          end)
        end,
        cssls = function()
          require("lazyvim.util").lsp.on_attach(function(client, _)
            if client.name == "cssls" then
              client.server_capabilities.documentFormattingProvider = false
            end
          end)
        end,
        svelte = function()
          require("lazyvim.util").lsp.on_attach(function(client, _)
            if client.name == "svelte" then
              client.server_capabilities.documentFormattingProvider = false
            end
          end)
        end,
        prismals = function()
          require("lazyvim.util").lsp.on_attach(function(client, _)
            if client.name == "prismals" then
              client.server_capabilities.documentFormattingProvider = false
            end
          end)
        end,
      },
    },
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        markdown = { "deno_fmt" },
        ruby = { "rubocop" },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        markdown = { "markdownlint" },
      },
    },
  },

  { "prisma/vim-prisma" },
}

-- return {
--   -- neodev
--   { "folke/neodev.nvim", opts = {} },
--
--   {
--     "VidocqH/lsp-lens.nvim",
--     opts = {
--       enable = true,
--       include_declaration = false, -- Reference include declaration
--       sections = { -- Enable / Disable specific request
--         definition = false,
--         references = true,
--         implementation = true,
--       },
--       ignore_filetype = {
--         "prisma",
--       },
--     },
--   },
-- }
