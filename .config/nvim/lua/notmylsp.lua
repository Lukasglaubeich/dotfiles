
-- ~/.config/nvim/lua/mylsp.lua
-- Diagnostics keymaps
local opts = { noremap=true, silent=true }
vim.api.nvim_set_keymap('n', ',e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
vim.api.nvim_set_keymap('n', 'ge', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
vim.api.nvim_set_keymap('n', 'gE', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
vim.api.nvim_set_keymap('n', ',q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

-- on_attach used for many servers
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Buffer local mappings for LSP
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 's', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'i', ',s', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', ',wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', ',wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', ',wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', ',D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', ',rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', ',qf', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', ',f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
end

-- Common requires
local lspconfig = require('lspconfig')
local configs = require('lspconfig.configs')
local util = lspconfig.util

-- Capabilities via nvim-cmp
local ok_cmp, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
local capabilities = vim.lsp.protocol.make_client_capabilities()
if ok_cmp and cmp_nvim_lsp and cmp_nvim_lsp.default_capabilities then
  capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.resolveSupport = {
  properties = { "documentation", "detail", "additionalTextEdits" },
}

-- Nim LSP
lspconfig.nimls.setup{
  cmd = { "nimlsp" },
  filetypes = { "nim" },
  single_file_support = true,
  on_attach = on_attach,
  capabilities = capabilities,
}

-- Clangd
lspconfig.clangd.setup{
  on_attach = on_attach,
  cmd = {
    "/opt/homebrew/opt/llvm/bin/clangd",
    "--background-index",
    "--pch-storage=memory",
    "--all-scopes-completion",
    "--pretty",
    "--header-insertion=never",
    "-j=4",
    "--inlay-hints",
    "--header-insertion-decorators",
    "--function-arg-placeholders",
    "--completion-style=detailed"
  },
  filetypes = {"c", "cpp", "objc", "objcpp"},
  root_dir = util.root_pattern("src"),
  init_option = { fallbackFlags = { "-std=c++2a" } },
  capabilities = capabilities,
}

-- Zig LSP
lspconfig.zls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { "zls", "--enable-debug-log" },
}

-- Pyright
lspconfig.pyright.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}

-- Monkey C / Garmin Connect IQ language server
-- Replace this jar path if your SDK is installed elsewhere
local jar = '/Users/familie/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-8.2.3-2025-08-11-cac5b3b21/bin/LanguageServer.jar'
local cmd_monkeyc = { 'java', '-jar', jar, '--stdio' } -- remove '--stdio' if it fails for you

-- Register custom server only once
if not configs.monkeyc then
  configs.monkeyc = {
    default_config = {
      cmd = cmd_monkeyc,
      filetypes = { 'mc', 'jungle', 'mss' },
      root_dir = util.root_pattern('manifest.xml', 'monkey.jungle', '.git'),
      settings = {},
    },
  }
end

-- Final setup call for monkeyc
lspconfig.monkeyc.setup{
  on_attach = on_attach,
  capabilities = capabilities,
}
