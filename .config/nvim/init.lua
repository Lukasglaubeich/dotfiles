-- init.lua (your file with diagnostics fixed for Neovim 0.11+)
vim.cmd("colorscheme catppuccin-frappe")

vim.o.termguicolors = true
vim.cmd("hi Normal guibg=NONE ctermbg=NONE")
vim.cmd("hi NonText guibg=NONE ctermbg=NONE")
vim.opt.mouse = ""
local modes = {"n", "i", "v", "c"}
local opts = { noremap = true, silent = true }
for _, key in ipairs({ "<Up>", "<Down>", "<Left>", "<Right>" }) do
	vim.keymap.set(modes, key, "<Nop>", opts)
end

require('plugins')

-- indent guides smooth scroll and notifications

require("ibl").setup()
require('neoscroll').setup()

vim.notify = require("notify")
vim.o.completeopt = "menuone,noselect"
vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.foldenable = false
vim.opt.number = true
vim.opt.relativenumber = true
vim.g.onedark_italic = 1


-- spectre
require('spectre').setup({
  live_update = true,
  ['run_replace'] = {
    map = "<leader>l",
    cmd = "<cmd>lua require('spectre.actions').run_replace()<CR>",
    desc = "replace all"
  },
  find_engine = {
    ['rg'] = {
      cmd = "rg",
      args = {
        '--color=never',
        '--no-heading',
        '--with-filename',
        '--line-number',
        '--column',
        '--pcre2',
      } ,
      options = {
        ['ignore-case'] = {
          value= "--ignore-case",
          icon="[I]",
          desc="ignore case"
        },
        ['hidden'] = {
          value="--hidden",
          desc="hidden file",
          icon="[H]"
        },
        -- you can put any rg search option you want here it can toggle with
        -- show_option function
      }
    },
  }
})

-- comma as leader
vim.g.mapleader = ","

-- load legacy options
vim.cmd([[
so ~/.config/nvim/legacy.vim
]])

require('mylsp')
require('nvimcmp')

require('symbols-outline').setup()

-- lsp_signature.nvim
require "lsp_signature".setup({
  hint_prefix = "",
  floating_window = false,
  bind = true,
})

-- lualine
require('lualine').setup{
  options = {
	  component_separators = {left = '', right = ''},
	  section_separators = {left = '', right = ''},
	  -- added
	  globalstatus = true,
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    -- lualine_c = {
    --  'filename',
    --  function()
    --    return vim.fn
    --  end},
--    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_x = {'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
}

-- nvim-treesitter
require('nvim-treesitter.configs').setup {
  highlight = {
    enable = true,
  },
}

require('nvim-autopairs').setup {}

-- nvim-dap
local dap = require('dap')
dap.adapters.lldb = {
  type = 'executable',
  command = 'lldb-vscode',
  name = 'lldb'
}

dap.configurations.cpp = {
  {
    name = 'Launch',
    type = 'lldb',
    request = 'launch',
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    args = {},
  },
}

-- same config for C
dap.configurations.c = dap.configurations.cpp


vim.api.nvim_create_autocmd({"BufRead","BufNewFile"}, {
  pattern = {"*.asm","*.s"},
  callback = function()
    vim.bo.filetype = "asm"
  end,
})

-- diagnostics: red dot + message at right, only for ERRORs (works on Neovim 0.11+)
do
  -- If `vim.diagnostic` exists (Neovim 0.6+ and improved in 0.11), use it.
  -- Otherwise fall back to the older LSP handler for compatibility.
  if vim.diagnostic then
    vim.diagnostic.config({
      virtual_text = {
        prefix = "● ",                                 -- red dot + space
        spacing = 2,
        -- show only ERROR-level virtual text to keep noise down
        severity = { min = vim.diagnostic.severity.ERROR },
        -- make messages single-line and truncate long ones
        format = function(diagnostic)
          local msg = diagnostic.message:gsub("\n", " ")
          local max = 160
          if #msg > max then
            return msg:sub(1, max - 3) .. "..."
          end
          return msg
        end,
        -- right-align the virtual text at end-of-line (truncates before covering text)
        virt_text_pos = "eol_right_align",
      },
      signs = true,
      underline = true,
      update_in_insert = false, -- keep this if you don't want flicker while typing
      severity_sort = true,
    })

    -- highlight for the virtual text (safe pcall in case colorscheme overrides)
    pcall(vim.cmd, [[highlight DiagnosticVirtualTextError guifg=#ff6b6b gui=bold]])
  else
    -- fallback for very old Neovim versions (unlikely for you, but safe)
    -- Note: older handler APIs differ in option names; this is a conservative config
    vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
      vim.lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = {
          prefix = "● ",
          spacing = 2,
        },
        signs = true,
        underline = true,
        update_in_insert = false,
      }
    )
    pcall(vim.cmd, [[highlight LspDiagnosticsVirtualTextError guifg=#ff6b6b gui=bold]])
  end
end

require("config.alpha")
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        local alpha = require("alpha")
        local dashboard = require("alpha.themes.dashboard")
        alpha.setup(dashboard.opts)
    end
})
