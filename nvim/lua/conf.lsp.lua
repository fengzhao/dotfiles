-- vim: foldmethod=marker foldenable
-- vim: tabstop=2 softtabstop=2 shiftwidth=2

-- nvim-cmp setup {{{
local cmp = require('cmp')

cmp.setup({
  preselect = cmp.PreselectMode.None,
  snippet = {
    expand = function(args)
      vim.fn['vsnip#anonymous'](args.body)
    end,
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
    { name = 'buffer' },
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
})
-- }}}

-- LSP Servers {{{
local capabilities = require('cmp_nvim_lsp').default_capabilities()

capabilities.offsetEncoding = { 'utf-16' }
capabilities.general = {
  positionEncodings = { 'utf-16' },
}

-- Go (gopls)
vim.lsp.config('gopls', { capabilities = capabilities })
vim.lsp.enable('gopls')

-- Python: ruff / pyright / pylsp
vim.lsp.config('ruff', {
  capabilities = capabilities,
  offset_encoding = 'utf-16',
  autostart = true,
})
vim.lsp.enable('ruff')

vim.lsp.config('pyright', {
  capabilities = capabilities,
  autostart = true,
  settings = {
    python = {
      useLibraryCodeForTypes = false,
      autoSearchPaths = true,
      diagnosticMode = 'openFilesOnly',
      analysis = {
        -- Ignore all files for analysis to exclusively use Ruff for linting
        ignore = { '*' },
      },
    },
  },
})
vim.lsp.enable('pyright')

vim.lsp.config('pylsp', {
  capabilities = capabilities,
  autostart = false,
  settings = {
    python = {
      analysis = {
        ignore = { '*' },
      },
    },
    pylsp = {
      configurationSources = {},
      plugins = {
        autopep8 = { enabled = false },
        flake8 = { enabled = false },
        yapf = { enabled = false },
        mccabe = { enabled = false },
        pycodestyle = { enabled = false },
        preload = { enabled = false },
        pyflakes = { enabled = false },
        pylint = { enabled = false },
        jedi_completion = { enabled = true },
      },
    },
  },
})
-- vim.lsp.enable('pylsp')

-- C/C++
vim.lsp.config('clangd', {
  capabilities = capabilities,
  filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
  cmd = {
    'clangd',
    '--offset-encoding=utf-16',
    '-j=1',
    '--background-index-priority=low',
    '--pch-storage=memory',
    -- '--clang-tidy',
  },
})
vim.lsp.enable('clangd')

-- CMake
vim.lsp.config('neocmake', {
  capabilities = capabilities,
})
vim.lsp.enable('neocmake')

-- Swift
vim.lsp.config('sourcekit', {
  capabilities = capabilities,
  filetypes = { 'swift' },
  cmd = { 'xcrun', '--toolchain', 'swift', 'sourcekit-lsp' },
})
vim.lsp.enable('sourcekit')

-- Dart
vim.lsp.config('dartls', {
  capabilities = capabilities,
  root_markers = { 'pubspec.yaml', '.git' },
})
vim.lsp.enable('dartls')

-- C#
vim.lsp.config('csharp_ls', {
  capabilities = capabilities,
  handlers = {
    ['textDocument/definition'] = require('csharpls_extended').handler,
  },
})
vim.lsp.enable('csharp_ls')

-- TypeScript（0.11 推荐 ts_ls）
vim.lsp.config('ts_ls', {
  capabilities = capabilities,
})
vim.lsp.enable('ts_ls')

-- Rust
vim.lsp.config('rust_analyzer', {
  capabilities = capabilities,
})
vim.lsp.enable('rust_analyzer')

-- bitproto（自定义服务）
vim.lsp.config['bitproto_language_server'] = {
  capabilities = capabilities,
  cmd = { 'bitproto-language-server' },
  filetypes = { 'bitproto' },
  root_markers = { '.git' },
}
vim.lsp.enable('bitproto_language_server')

-- Lua
vim.lsp.config('lua_ls', {
  capabilities = capabilities,
})
vim.lsp.enable('lua_ls')

-- ===============================
-- Auto commands & Keymaps on LspAttach {{{
-- ===============================
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    -- === LSP 快捷键（注意 buffer = args.buf）
    vim.keymap.set('n', 'gd', function()
      vim.cmd('split')
      vim.lsp.buf.definition()
    end, { silent = true, buffer = args.buf })

    vim.keymap.set('n', 'gv', function()
      vim.cmd('vsplit')
      vim.lsp.buf.definition()
    end, { silent = true, buffer = args.buf })

    vim.keymap.set('n', 'gD', function()
      vim.cmd('split')
      vim.lsp.buf.declaration()
    end, { silent = true, buffer = args.buf })

    vim.keymap.set('n', 'gr', function()
      vim.cmd('split')
      vim.lsp.buf.references()
    end, { silent = true, buffer = args.buf })

    vim.keymap.set('n', 'gi', function()
      vim.cmd('split')
      vim.lsp.buf.implementation()
    end, { silent = true, buffer = args.buf })

    vim.keymap.set('n', '<c-k>', function()
      vim.lsp.buf.signature_help()
    end, { silent = true, buffer = args.buf })

    vim.keymap.set('n', 'K', function()
      vim.lsp.buf.hover()
    end, { silent = true, buffer = args.buf })

    vim.keymap.set('n', 'grn', function()
      vim.lsp.buf.rename()
    end, { silent = true, buffer = args.buf })

    -- === 在当前行 CursorHold 时，把最严重的一条诊断 echo 到命令行
    local diag_group = vim.api.nvim_create_augroup('LspDiagEcho' .. args.buf, { clear = true })
    vim.api.nvim_create_autocmd('CursorHold', {
      group = diag_group,
      buffer = args.buf,
      callback = function()
        local curline = vim.api.nvim_win_get_cursor(0)[1]
        local list = vim.diagnostic.get(args.buf, { lnum = curline - 1 })
        if #list > 0 then
          local _, first = next(list)
          vim.api.nvim_echo({ { ((first.source or 'LSP') .. ': ' .. first.message), 'WarningMsg' } }, false, {})
        end
      end,
    })

    -- === 保存前格式化（每个 buffer 单独 augroup）
    local fmt_group = vim.api.nvim_create_augroup('LspFormatting' .. args.buf, { clear = true })
    vim.api.nvim_create_autocmd('BufWritePre', {
      group = fmt_group,
      buffer = args.buf,
      callback = function()
        vim.lsp.buf.format({ async = false })
      end,
    })

    -- === Hover / SignatureHelp 浮窗边框
    vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'single' })
    vim.lsp.handlers['textDocument/signatureHelp'] =
      vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'single' })
  end,
})
-- }}}

-- ===============================
-- Diagnostics Config {{{
-- ===============================
vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  float = { border = 'none' },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})
-- }}}

-- ===============================
-- Symbols Outline {{{
-- ===============================
require('outline').setup({})
-- }}}
