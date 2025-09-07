vim.cmd("colorscheme onedark")

vim.o.termguicolors = true
vim.opt.mouse = ""
local modes = {"n", "i", "v", "c"}
local opts = { noremap = true, silent = true }
for _, key in ipairs({ "<Up>", "<Down>", "<Left>", "<Right>" }) do
	vim.keymap.set(modes, key, "<Nop>", opts)
end

require('plugins')

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
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {
      'filename',
      function()
        return vim.fn['nvim_treesitter#statusline'](180)
      end},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
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

vim.diagnostics.config({
	virtual_text = {
		prefix = "● ",
		spacing = 2,
		severity = { min = vim.diagnostics.severity.ERROR },
		format = function(diagnostic)
			local msg = diagnostic.message:gsub("\n", " ")
			if #msg > 180 then
				return msg:sub(1,177) .. "…"
			end
			return msg
		end,
	},
	signs = true,
	underline = true,
	update_in_insert = false,
})

vim.cmd([[highlight DiagnosticVirtualTextError guifg=#ff6b6b gui=bold]])
