-- ~/.config/nvim/lua/mylsp.lua
-- Migration to vim.lsp.config (Neovim 0.11+)
-- Diagnostics keymaps
local opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap('n', ',e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
vim.api.nvim_set_keymap('n', 'ge', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
vim.api.nvim_set_keymap('n', 'gE', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
vim.api.nvim_set_keymap('n', ',q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

-- on_attach used for many servers
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Buffer local mappings for LSP
  local buf_opts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, buf_opts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, buf_opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, buf_opts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, buf_opts)
  vim.keymap.set('n', 's', vim.lsp.buf.signature_help, buf_opts)
  vim.keymap.set('i', ',s', vim.lsp.buf.signature_help, buf_opts)
  vim.keymap.set('n', ',wa', vim.lsp.buf.add_workspace_folder, buf_opts)
  vim.keymap.set('n', ',wr', vim.lsp.buf.remove_workspace_folder, buf_opts)
  vim.keymap.set('n', ',wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, buf_opts)
  vim.keymap.set('n', ',D', vim.lsp.buf.type_definition, buf_opts)
  vim.keymap.set('n', ',rn', vim.lsp.buf.rename, buf_opts)
  vim.keymap.set('n', ',qf', vim.lsp.buf.code_action, buf_opts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, buf_opts)
  vim.keymap.set('n', ',f', function() vim.lsp.buf.format({ async = true }) end, buf_opts)
end

-- util from lspconfig
local util = require('lspconfig.util')

-- Capabilities via nvim-cmp (if available)
local ok_cmp, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
local capabilities = vim.lsp.protocol.make_client_capabilities()
if ok_cmp and cmp_nvim_lsp and cmp_nvim_lsp.default_capabilities then
  capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end
capabilities.textDocument = capabilities.textDocument or {}
capabilities.textDocument.completion = capabilities.textDocument.completion or {}
capabilities.textDocument.completion.completionItem = capabilities.textDocument.completion.completionItem or {}
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.resolveSupport = {
  properties = { "documentation", "detail", "additionalTextEdits" },
}

-- Helper: safely extend/merge server default_config
local function extend_server(server_name, tbl)
  vim.lsp.config[server_name] = vim.lsp.config[server_name] or {}
  vim.lsp.config[server_name].default_config = vim.tbl_deep_extend(
    "force",
    vim.lsp.config[server_name].default_config or {},
    tbl or {}
  )
end

-- ---- Servers configuration ----

-- Nim LSP
extend_server("nimls", {
  cmd = { "nimlsp" },
  filetypes = { "nim" },
  single_file_support = true,
  on_attach = on_attach,
  capabilities = capabilities,
})

-- Clangd
extend_server("clangd", {
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
  filetypes = { "c", "cpp", "objc", "objcpp" },
  -- ensure root_dir is a function that receives filename
  root_dir = function(fname)
    return util.root_pattern("src", ".git")(fname)
  end,
  -- keep both names (original had `init_option`): prefer `init_options`
  init_options = { fallbackFlags = { "-std=c++2a" } },
  init_option = { fallbackFlags = { "-std=c++2a" } },
  on_attach = on_attach,
  capabilities = capabilities,
})

-- Zig LSP (zls)
extend_server("zls", {
  cmd = { "zls", "--enable-debug-log" },
  on_attach = on_attach,
  capabilities = capabilities,
})

-- Pyright
extend_server("pyright", {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  on_attach = on_attach,
  capabilities = capabilities,
})

-- Monkey C / Garmin Connect IQ language server (custom registration)
local jar = '/Users/familie/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-8.2.3-2025-08-11-cac5b3b21/bin/LanguageServer.jar'
local cmd_monkeyc = { 'java', '-jar', jar, '--stdio' } -- remove '--stdio' if it fails for you

if not vim.lsp.config.monkeyc then
  vim.lsp.config.monkeyc = {
    default_config = {
      cmd = cmd_monkeyc,
      filetypes = { 'mc', 'jungle', 'mss' },
      root_dir = function(fname)
        return util.root_pattern('manifest.xml', 'monkey.jungle', '.git')(fname)
      end,
      settings = {},
    },
  }
else
  -- if it exists upstream, merge our defaults
  extend_server("monkeyc", {
    cmd = cmd_monkeyc,
    filetypes = { 'mc', 'jungle', 'mss' },
    root_dir = function(fname)
      return util.root_pattern('manifest.xml', 'monkey.jungle', '.git')(fname)
    end,
    settings = {},
    on_attach = on_attach,
    capabilities = capabilities,
  })
end

-- List of servers to enable
local servers_to_enable = { "nimls", "clangd", "zls", "pyright", "monkeyc" }
vim.lsp.enable(servers_to_enable)
