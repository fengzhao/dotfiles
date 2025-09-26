-- Quickfix
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local grp = vim.api.nvim_create_augroup('DiagLoclistRefresh_' .. ev.buf, { clear = true })

    -- helper：当前窗口的 loclist 是否可见
    local function loclist_visible(win)
      local info = vim.fn.getloclist(win, { winid = 1 })
      return info and info.winid and info.winid ~= 0
    end

    -- 刷新当前窗口的 loclist
    -- open_mode: 'visible' 仅在已打开时保持打开；'always' 总是打开
    local function refresh_loclist(open_mode)
      -- 在 qf/loclist 窗口里不要刷新，避免打断 <CR>
      if vim.bo.filetype == 'qf' then
        return
      end
      local win = vim.api.nvim_get_current_win()
      local should_open = (open_mode == 'always') or (open_mode == 'visible' and loclist_visible(win))
      -- 关键：绑定 owner 到“当前窗口”，避免 <CR> 跳错
      vim.diagnostic.setloclist({ open = should_open, winnr = win })
    end

    -- buf-local 的 :Quickfix 命令（可选严重级别）
    vim.api.nvim_buf_create_user_command(ev.buf, 'Quickfix', function(opts)
      local win = vim.api.nvim_get_current_win()
      local sev
      if opts.args ~= '' then
        local S = vim.diagnostic.severity
        sev = ({ ERROR = S.ERROR, WARN = S.WARN, INFO = S.INFO, HINT = S.HINT })[string.upper(opts.args)]
      end
      vim.diagnostic.setloclist({ open = true, winnr = win, severity = sev })
    end, {
      desc = 'Diagnostics -> location list (current window)',
      nargs = '?',
      complete = function()
        return { 'ERROR', 'WARN', 'INFO', 'HINT' }
      end,
    })

    -- 自动刷新：仅在 loclist 已打开时刷新
    vim.api.nvim_create_autocmd('DiagnosticChanged', {
      group = grp,
      callback = function(a)
        if a.buf ~= ev.buf then
          return
        end -- 只处理本 buffer 的诊断变化
        refresh_loclist('visible')
      end,
    })

    vim.api.nvim_create_autocmd('BufWritePost', {
      group = grp,
      buffer = ev.buf, -- 只在本 buffer 保存后刷新
      callback = function()
        refresh_loclist('visible')
      end,
    })

    -- 如需离开/切换窗口也刷新，可加（注意保留 filetype==qf 的保护）
    -- vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter' }, {
    --   group = grp, buffer = ev.buf,
    --   callback = function() refresh_loclist('visible') end,
    -- })
  end,
})
