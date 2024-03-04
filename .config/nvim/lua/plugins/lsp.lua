return {
  "neovim/nvim-lspconfig",
  event = "BufReadPost",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    -- Install neodev for better nvim configuration and plugin authoring via lsp configurations
    "folke/neodev.nvim",
  },
  config = function()
    local masonLspConfig = require("mason-lspconfig")
    local lspconfig = require("lspconfig")
    local mason = require("mason")

    mason.setup({})

    masonLspConfig.setup({
      ensure_installed = {
        "lua_ls",
        "astro",
        "solargraph",
        "tsserver",
        "html",
        "cssls",
        "tailwindcss",
        "svelte",
        "graphql",
        "prismals",
        "mdx_analyzer",
      }
    })

    -- Lsp server list https://github.com/williamboman/mason-lspconfig.nvim#available-lsp-servers
    lspconfig.lua_ls.setup({
      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            library = {
              [vim.fn.expand "$VIMRUNTIME/lua"] = true,
              [vim.fn.stdpath "config" .. "/lua"] = true,
            },
          },
        },
      },
    })
    lspconfig.solargraph.setup({})
    lspconfig.tsserver.setup({})
    lspconfig.html.setup({})
    lspconfig.cssls.setup({})
    lspconfig.tailwindcss.setup({})
    lspconfig.svelte.setup({})
    lspconfig.graphql.setup({})
    lspconfig.svelte.setup({})
    lspconfig.prismals.setup({})
    lspconfig.mdx_analyzer.setup({})

    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('UserLspConfig', {}),
      callback = function(ev)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<space>f', function()
          vim.lsp.buf.format { async = true }
        end, opts)
      end,
    })
  end
}
