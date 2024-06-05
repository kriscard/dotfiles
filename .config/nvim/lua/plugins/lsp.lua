return {
  "neovim/nvim-lspconfig",
  event = "BufReadPost",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    -- Install neodev for better nvim configuration and plugin authoring via lsp configurations
    "folke/neodev.nvim",
    "nvimtools/none-ls.nvim",
    "nvimtools/none-ls-extras.nvim",
    "nvim-lua/plenary.nvim",
  },
  debug = true,
  config = function()
    local mason = require("mason")
    local null_ls = require("null-ls")
    local masonLspConfig = require("mason-lspconfig")
    local lspconfig = require("lspconfig")

    masonLspConfig.setup({
      automatic_installation = true,
    })

    mason.setup({
      ui = {
        border = "rounded",
      },
    })

    null_ls.setup({
      sources = {
        require("none-ls.diagnostics.eslint"),
        require("none-ls.code_actions.eslint"),
        null_ls.builtins.completion.spell,
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.formatting.markdownlint,
      },
    })

    -- Use neodev to configure lua_ls in nvim directories - must load before lspconfig
    require("neodev").setup()
    -- Lsp server list https://github.com/williamboman/mason-lspconfig.nvim#available-lsp-servers
    --
    lspconfig.eslint.setup({
      --- ...
      on_attach = function(client, bufnr)
        vim.api.nvim_create_autocmd("BufWritePre", {
          buffer = bufnr,
          command = "EslintFixAll",
        })
      end,
    })

    local servers = {
      solargraph = {},
      bashls = {},
      cssls = {},
      graphql = {},
      html = {},
      jsonls = {},
      lua_ls = {
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
          },
        },
      },
      marksman = {},
      prismals = {},
      sqlls = {},
      tailwindcss = {
        experimental = {
          classRegex = {
            { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
            { "cx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
          },
        },
      },
      tsserver = {},
      yamlls = {},
    }

    -- Default handlers for LSP
    local default_handlers = {
      ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" }),
      ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" }),
    }

    -- nvim-cmp supports additional completion capabilities
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local default_capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

    ---@diagnostic disable-next-line: unused-local
    local on_attach = function(_client, buffer_number)
      -- Create a command `:Format` local to the LSP buffer
      vim.api.nvim_buf_create_user_command(buffer_number, "Format", function(_)
        vim.lsp.buf.format({
          filter = function(format_client)
            -- Use Prettier to format TS/JS if it's available
            return format_client.name ~= "tsserver" or not null_ls.is_registered("prettier")
          end,
        })
      end, { desc = "LSP: Format current buffer with LSP" })
    end

    -- Iterate over our servers and set them up
    for name, config in pairs(servers) do
      require("lspconfig")[name].setup({
        capabilities = default_capabilities,
        filetypes = config.filetypes,
        handlers = vim.tbl_deep_extend("force", {}, default_handlers, config.handlers or {}),
        on_attach = on_attach,
        settings = config.settings,
      })
    end

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf }
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
        vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
        vim.keymap.set("n", "<space>wl", function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, opts)
        vim.keymap.set("n", "rn", vim.lsp.buf.rename, opts)
        vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<space>F", function()
          vim.lsp.buf.format({ async = true, desc = "Formatting file" })
        end, opts)
        vim.keymap.set("n", "<leader>cr", "<cmd>LspRestart<cr>", { desc = "Restart LSP" })
      end,
    })

    -- Configure borderd for LspInfo ui
    require("lspconfig.ui.windows").default_options.border = "rounded"
  end,
}
