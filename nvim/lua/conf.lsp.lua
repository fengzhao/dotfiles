-- vim: foldmethod=marker foldenable
-- vim: tabstop=2 softtabstop=2 shiftwidth=2

-- nvim-cmp setup {{{
local cmp = require('cmp')
local nvim_lsp = require('lspconfig')

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
    -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
})
--- }}}

--  Lsp Servers {{{
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Make a root_dir function, searching some files at first and then fallback to cwd.
function make_root_dir_function(...)
  local patterns = { ... }
  return function(fname)
    return nvim_lsp.util.root_pattern(unpack(patterns))(fname) or vim.fn.getcwd()
  end
end

-- Golang
require('lspconfig')['gopls'].setup({
  capabilities = capabilities,
})

-- Python ruff, pyright & pylsp

require('lspconfig').ruff.setup({ -- ruff for formatting and lint
  capabilities = capabilities,
  autostart = true,
})

require('lspconfig')['pyright'].setup({ -- pyright for completion and go-to-definitions
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

require('lspconfig').pylsp.setup({ -- As an alternative to pyright, sometimes pyright dies.
  capabilities = capabilities,
  autostart = false,
  settings = {
    python = {
      analysis = {
        -- Ignore all files for analysis to exclusively use Ruff for linting
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
        jedi_completion = {
          enabled = true,
        },
      },
    },
  },
})

-- C/C++
require('lspconfig')['clangd'].setup({
  capabilities = capabilities,
  filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
  cmd = {
    'clangd',
    '--offset-encoding=utf-16',
    '-j=1',
    -- '--background-index',
    '--background-index-priority=low',
    '--pch-storage=memory',
    -- by default, clang-tidy use -checks=clang-diagnostic-*,clang-analyzer-*
    -- to add more checks, create .clang-tidy file in the root directory
    -- and add Checks key, see https://clang.llvm.org/extra/clang-tidy/
    -- This is slow..
    --    '--clang-tidy',
  },
})

-- CMake
require('lspconfig').neocmake.setup({
  capabilities = capabilities,
})

-- Swift: Better to use along with https://github.com/SolaWing/xcode-build-server on xcode projects.
require('lspconfig').sourcekit.setup({
  capabilities = capabilities,
  -- filetypes = { 'swift', 'objective-c', 'objective-cpp' },
  filetypes = { 'swift' },
  cmd = { 'xcrun', '--toolchain', 'swift', 'sourcekit-lsp' },
})

-- Dart
require('lspconfig').dartls.setup({
  capabilities = capabilities,
  root_dir = make_root_dir_function('pubspec.yaml', '.git'),
})

-- CSharp
require('lspconfig')['csharp_ls'].setup({
  capabilities = capabilities,
  handlers = {
    ['textDocument/definition'] = require('csharpls_extended').handler,
  },
})

-- Typescript
require('lspconfig')['ts_ls'].setup({})

-- Rust
require('lspconfig')['rust_analyzer'].setup({
  capabilities = capabilities,
})


-- bitproto
local lspconfig_configs = require("lspconfig.configs") 

if not lspconfig_configs.bitproto_language_server then
  lspconfig_configs.bitproto_language_server = {
    default_config = {
      name = "bitproto_language_server",
      cmd = {"bitproto-language-server"},
      filetypes = { 'bitproto' },
      root_dir = function(fname)
        return require('lspconfig').util.find_git_ancestor(fname) or vim.fn.getcwd()
      end,
    },
  }
end

require('lspconfig').bitproto_language_server.setup{}
--}}}

-- Auto commands && Key bindings on Lsp Attach {{{
-- server_ready is deprecated since 0.10, use LspAttach instead
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    -- Lsp Key Mapping -- {{{
    ---- gd: Split and Go to Definition
    vim.keymap.set('n', 'gd', function()
      vim.cmd('split')
      vim.lsp.buf.definition()
    end, { silent = true, buffer = true })
    ---- gv: VSplit and Go to Definition
    vim.keymap.set('n', 'gv', function()
      vim.cmd('vsplit')
      vim.lsp.buf.definition()
    end, { silent = true, buffer = true })
    ---- gD: Split and Go to Declaration
    vim.keymap.set('n', 'gD', function()
      vim.cmd('split')
      vim.lsp.buf.declaration()
    end, { silent = true, buffer = true })
    ---- gr: Split and show References of current symbol
    vim.keymap.set('n', 'gr', function()
      vim.cmd('split')
      vim.lsp.buf.references()
    end, { silent = true, buffer = true })
    ---- gi: Split and show Implementations
    vim.keymap.set('n', 'gi', function()
      vim.cmd('split')
      vim.lsp.buf.implementation()
    end, { silent = true, buffer = true })
    ---- Ctrl-k: Show SignatureHelp
    vim.keymap.set('n', '<c-k>', function()
      vim.lsp.buf.signature_help()
    end, { silent = true, buffer = true })
    ---- K: Hover, something like usage manual, introduction stuffs.
    vim.keymap.set('n', 'K', function()
      vim.lsp.buf.hover()
    end, { silent = true, buffer = true })
    ---- grn: rename 
    vim.keymap.set('n', 'grn', function()
      vim.lsp.buf.rename()
    end, { silent = true, buffer = true })

    -- End lsp key mapping }}}

    -- Show Diagnostics on cursor hold for current line
    vim.api.nvim_create_autocmd('CursorHold', {
      pattern = '*',
      callback = function()
        -- Instead of vim.diagnostic.open_float(0, { scope = 'line', source = true, focus = false })
        -- I don't like diagnostics messages show directly on the screen near my code and cursor.
        -- This may mess up my editing. So I echo it to the command-bar.
        local curline = vim.api.nvim_win_get_cursor(0)[1]
        local diagnostics_list = vim.diagnostic.get(args.buf, { lnum = curline - 1 })
        if #diagnostics_list > 0 then
          -- We just show the first diagnostics message.
          -- We already have `severity_sort` set, so it's the most serious one.
          local _, first = next(diagnostics_list)
          -- nvim_echo receives a chunck of pairs, each pair has the structure { message, HiGroup }
          -- Here we use the colors of Warnings.
          -- The `source` is the linter stuff which produces this message (e.g. mypy)
          vim.api.nvim_echo({ { first.source .. ': ' .. first.message, 'WarningMsg' } }, false, {})
        end
      end,
    })
    -- Formatting on (pre) save. {{{
    -- vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
    local augroup = vim.api.nvim_create_augroup('LspFormatting', {})

    vim.api.nvim_create_autocmd('BufWritePre', {
      group = augroup,
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ async = false })
      end,
    }) -- }}}

    -- Lsp Hover & SignatureHelp Configurations {{{
    -- Single border for hover floating window.
    vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
      border = 'single',
    })

    -- Single border for signature help window.
    vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, {
      border = 'single',
    })

    -- Single border for :LspInfo window.
    require('lspconfig.ui.windows').default_options = {
      border = 'single',
    }
    -- }}}
  end,
})
--  }}}

-- Diagnostics Config {{{
vim.diagnostic.config({
  virtual_text = false, -- virtual_text is too noisy, we disable it.
  signs = true,
  float = { border = 'none' },
  underline = true,
  update_in_insert = false,
  -- higher severities are displayed before lower severities
  severity_sort = true,
})
--- }}}

-- Symbols Outline {{{
require("outline").setup{}
-- }}}
