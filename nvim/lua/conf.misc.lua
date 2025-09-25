-- vim: foldmethod=marker foldenable
-- vim: tabstop=2 softtabstop=2 shiftwidth=2

-- Misc Plugins

-- Plugin erhickey/sig-window-nvim {{{
-- https://github.com/hit9/sig-window-nvim
require('sig-window-nvim').setup({
  window_config = function(label, config, width, height)
    return {
      relative = 'cursor',
      anchor = 'SW',
      width = width,
      height = height,
      row = -1,
      col = 3,
      focusable = false,
      zindex = config.zindex,
      style = 'minimal',
      border = config.border,
    }
  end,
  max_height = 100,
  border = 'single',
  hl_group = 'Visual',
})

-- End sig-window-nvim }}}

-- Plugin windwp/nvim-autopairs {{{
require('nvim-autopairs').setup({})
-- }}}

-- Plugin https://sr.ht/~p00f/godbolt.nvim/  for C++ {{{
require('godbolt').setup({
  languages = {
    cpp = { compiler = 'clang1600', options = { userArguments = '-std=c++20' } },
    c = { compiler = 'clang1600', options = {} },
  },
  quickfix = {
    enable = true, -- whether to populate the quickfix list in case of errors
    auto_open = false, -- whether to open the quickfix list in case of errors
  },
  url = 'https://godbolt.org', -- can be changed to a different godbolt instance
})
-- end godbolt }}}

-- indent-blankline {{{
local highlight = {
  'RainbowRed',
  'RainbowYellow',
  'RainbowBlue',
  'RainbowOrange',
  'RainbowGreen',
  'RainbowViolet',
  'RainbowCyan',
}

local hooks = require('ibl.hooks')

local palettes = {
  -- 柔和莫卡（暗色系，灵感自 Catppuccin Mocha）
  mocha = {
    Red = '#F38BA8',
    Yellow = '#F9E2AF',
    Blue = '#89B4FA',
    Orange = '#FAB387',
    Green = '#A6E3A1',
    Violet = '#CBA6F7',
    Cyan = '#94E2D5',
    Scope = '#BAC2DE', -- 作用域线颜色（更浅一点）
  },
  -- 清爽拿铁（亮色系，适合浅色主题）
  latte = {
    Red = '#D7005F',
    Yellow = '#B58900',
    Blue = '#268BD2',
    Orange = '#CB4B16',
    Green = '#2AA198',
    Violet = '#6C71C4',
    Cyan = '#2AA1B3',
    Scope = '#93A1A1',
  },
  -- 北境微雾（低饱和、通用耐看）
  nord = {
    Red = '#BF616A',
    Yellow = '#EBCB8B',
    Blue = '#81A1C1',
    Orange = '#D08770',
    Green = '#A3BE8C',
    Violet = '#B48EAD',
    Cyan = '#88C0D0',
    Scope = '#AAB3BF',
  },
}

local function apply_ibl_palette(name)
  local p = palettes[name] or palettes.mocha
  local hooks = require('ibl.hooks')
  hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
    vim.api.nvim_set_hl(0, 'RainbowRed', { fg = p.Red })
    vim.api.nvim_set_hl(0, 'RainbowYellow', { fg = p.Yellow })
    vim.api.nvim_set_hl(0, 'RainbowBlue', { fg = p.Blue })
    vim.api.nvim_set_hl(0, 'RainbowOrange', { fg = p.Orange })
    vim.api.nvim_set_hl(0, 'RainbowGreen', { fg = p.Green })
    vim.api.nvim_set_hl(0, 'RainbowViolet', { fg = p.Violet })
    vim.api.nvim_set_hl(0, 'RainbowCyan', { fg = p.Cyan })
    vim.api.nvim_set_hl(0, 'RainbowScope', { fg = p.Scope })
  end)
end

-- 选择一个：'mocha' | 'latte' | 'nord'
apply_ibl_palette('nord')

require('ibl').setup({
  indent = { highlight = highlight, char = '▏' }, -- char 可以选: ▏, ┊
})
-- end indent-blankline }}}
