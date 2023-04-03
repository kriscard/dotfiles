local lsp = require("lsp-zero")
lsp.preset("recommended")

lsp.ensure_installed({
  'tsserver',
  'eslint',
  'tailwindcss',
  'lua_ls',
})

-- Fix Undefined global 'vim'
lsp.configure('lualanguage-server', {
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim' }
      }
    }
  }
})

lsp.set_preferences({
  sign_icons = { error = " ", warn = " ", hint = " ", info = " " }
})

require 'lspconfig'.tsserver.setup {
  filetypes = { "javscript", "typescript", "typescriptreact", "typescript.tsx" },
  root_dir = function() return vim.loop.cwd() end
}

local lspkind = require('lspkind')
local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Insert }

local cmp_mappings = lsp.defaults.cmp_mappings({
  ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
  ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
  ['<C-y>'] = cmp.mapping.confirm({ select = true }),
  ["<C-Space>"] = cmp.mapping.complete(),
  ['<Tab>'] = cmp.mapping.select_next_item({ behaviour = cmp.SelectBehavior.Insert }),
  ['<S-Tab>'] = cmp.mapping.select_prev_item({ behaviour = cmp.SelectBehavior.Insert }),
  ["<CR>"] = cmp.mapping.confirm({
    -- this is the important line
    behavior = cmp.ConfirmBehavior.Replace,
    select = false,
  }),
})

lsp.setup_nvim_cmp({
  mapping = cmp_mappings,
  sources = {
    { name = 'path' },
    { name = 'nvim_lsp', group_index = 1 },
    { name = "copilot",  group_index = 2 },
    { name = 'luasnip',  group_index = 3 },
    { name = 'buffer',   group_index = 2 },
  },
  formatting = {
    format = lspkind.cmp_format({
      mode = 'symbol_text',
      max_width = 50,
      ellipsis_char = '...',
      preset = 'codicons',
      symbol_map = {
        Copilot = "",
        Text = "",
        Method = "",
        Function = "",
        Constructor = "",
        Field = "ﰠ",
        Variable = "",
        Class = "ﴯ",
        Interface = "",
        Module = "",
        Property = "ﰠ",
        Unit = "塞",
        Value = "",
        Enum = "",
        Keyword = "",
        Snippet = "",
        Color = "",
        File = "",
        Reference = "",
        Folder = "",
        EnumMember = "",
        Constant = "",
        Struct = "פּ",
        Event = "",
        Operator = "",
        TypeParameter = ""
      },
    })
  },
})

lsp.on_attach(function(client, bufnr)
  local opts = { buffer = bufnr, remap = false }

  vim.keymap.set("n", "gd", '<cmd>Telescope lsp_definitions<CR>', opts)
  vim.keymap.set("n", "gr", '<cmd>Telescope lsp_references<CR>', opts)
  vim.keymap.set("n", "<leader>ws", function() vim.lsp.buf.workspace_symbol() end, opts)
  vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
  vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
  vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
  vim.keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end, opts)
  vim.keymap.set("n", "<leader>rr", function() vim.lsp.buf.references() end, opts)
  vim.keymap.set("n", "<leader>rn", function() vim.lsp.buf.rename() end, opts)
  vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
end)

lsp.setup()

vim.o.updatetime = 250
vim.cmd [[autocmd! CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]]

vim.diagnostic.config({
  virtual_text = true
})
