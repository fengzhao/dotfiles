-- vim: foldmethod=marker foldenable
-- vim: tabstop=2 softtabstop=2 shiftwidth=2

-- Misc Plugins

-- Plugin erhickey/sig-window-nvim {{{
-- https://github.com/erhickey/sig-window-nvim
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
require('indent_blankline').setup({
  show_current_context = true,
  show_current_context_start = false,
})
-- end indent-blankline }}}
