local setup, null_ls = pcall(require, "null-ls")
if not setup then
  return
end

null_ls.setup {
  sources = {
    null_ls.builtins.formatting.prettierd,
  }
}

local status, prettier = pcall(require, "prettier")
if (not status) then return end

prettier.setup {
  bin = 'prettierd',
  filetypes = {
    "css",
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "json",
    "scss",
    "less"
  }
}
