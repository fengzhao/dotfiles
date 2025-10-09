-- Copy import path for Python: <module.dotted.path>.<symbol_under_cursor>
-- - 模块名通过向上查找含 __init__.py 的包层级推导
-- - 文件名为 __init__.py 时，模块名不追加该层
-- - 标识符来自光标下的 <cword>
-- - 结果写入系统剪贴板（+ 寄存器），并以 :echo 显示

local function is_file(path)
  return vim.loop.fs_stat(path) ~= nil
end

local function join_paths(...)
  return table.concat({ ... }, '/')
end

local function filepath_to_module(bufpath)
  if not bufpath or bufpath == '' then
    return nil
  end
  -- 规范化
  bufpath = vim.fn.fnamemodify(bufpath, ':p') -- 绝对路径
  local dir = vim.fn.fnamemodify(bufpath, ':h')
  local file = vim.fn.fnamemodify(bufpath, ':t') -- 文件名

  -- 向上寻找连续的包（含 __init__.py）
  local parts = {}
  local prev = nil
  while dir and dir ~= prev do
    if is_file(join_paths(dir, '__init__.py')) then
      table.insert(parts, 1, vim.fn.fnamemodify(dir, ':t')) -- 头插
      prev = dir
      dir = vim.fn.fnamemodify(dir, ':h')
    else
      break
    end
  end

  -- 追加当前文件名（若不是 __init__.py）
  if file ~= '__init__.py' then
    local mod = vim.fn.fnamemodify(file, ':r') -- 去掉 .py
    if mod ~= '' then
      table.insert(parts, mod)
    end
  end

  if #parts == 0 then
    -- 退化策略：用相对工作目录的路径推导一次（不强制）
    local rel = vim.fn.fnamemodify(bufpath, ':.')
    rel = rel:gsub('%.py$', ''):gsub('/', '.'):gsub('^%./', '')
    return rel
  end

  return table.concat(parts, '.')
end

local function copy_import_path()
  -- 仅在 python buffer 下工作
  if vim.bo.filetype ~= 'python' then
    vim.notify('CopyImportPath 仅用于 Python 文件', vim.log.levels.WARN)
    return
  end

  local buf = vim.api.nvim_get_current_buf()
  local path = vim.api.nvim_buf_get_name(buf)
  local module = filepath_to_module(path)
  if not module or module == '' then
    vim.notify('未能推导模块路径', vim.log.levels.ERROR)
    return
  end

  -- 光标下标识符
  local ident = vim.fn.expand('<cword>')
  -- 若 ident 为空，就只复制模块名
  local import_path = ident ~= '' and (module .. '.' .. ident) or module

  -- 复制到系统剪贴板
  pcall(vim.fn.setreg, '+', import_path)
  -- 也写到无名寄存器，方便粘贴
  pcall(vim.fn.setreg, '"', import_path)

  vim.notify('Copied: ' .. import_path, vim.log.levels.INFO, { title = 'CopyImportPath' })
end

-- 只在 Python 文件里注册命令（缓冲区级）
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'python',
  callback = function(args)
    vim.api.nvim_buf_create_user_command(
      args.buf,
      'CopyImportPath',
      copy_import_path,
      { desc = 'Copy Python import path' }
    )
  end,
})
