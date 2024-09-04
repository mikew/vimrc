local mod = {
  features = {},
}

function mod.register_feature(name)
  if not vim.list_contains(mod.features, name) then
    table.insert(mod.features, name)
  end
end

function mod.has_feature(name)
  return vim.list_contains(mod.features, name)
end

function mod.determine_ui()
  local force_ui = os.getenv('NVIM_FORCE_UI')
  if force_ui ~= nil then
    return force_ui
  end

  if vim.g.neovide then
    return 'neovide'
  end

  if
    vim.tbl_contains(vim.v.argv, function(v)
      return string.find(v, 'nvim-qt', 1, true)
    end, { predicate = true })
  then
    return 'nvim-qt'
  end

  return 'term'
end

function mod.has_gui_running()
  return mod.determine_ui() ~= 'term'
end

function mod.better_tabdo(callback)
  local current_tab = vim.api.nvim_tabpage_get_number(0)
  callback()
  vim.cmd('tabnext ' .. current_tab)
end

function mod.create_augroup(name, clear)
  clear = clear == nil and true or clear
  return vim.api.nvim_create_augroup('vimrc_' .. name, { clear = clear })
end

function mod.determine_os()
  local force_os = os.getenv('NVIM_FORCE_OS')
  if force_os ~= nil then
    return force_os
  end

  local os = vim.loop.os_uname().sysname

  if os == 'Linux' then
    return 'linux'
  elseif os == 'Darwin' then
    return 'macos'
  elseif os == 'Windows' then
    return 'windows'
  end
end

--- @class GetWindowInfoResult
--- @field winid integer
--- @field bufnr integer
--- @field tabpage integer
--- @field bufname string

--- @param path string
function mod.get_window_info_for_file(path)
  local path_with_cwd = vim.fn.fnamemodify(path, ':p')

  for _, winid in ipairs(vim.api.nvim_list_wins()) do
    local bufnr = vim.api.nvim_win_get_buf(winid)
    -- Intentionally use `bufname` instead of `nvim_buf_get_name` because
    -- because the latter always returns a full path.
    local bufname = vim.fn.bufname(bufnr)

    if bufname == path or bufname == path_with_cwd then
      local tabpage = vim.api.nvim_win_get_tabpage(winid)
      --- @type GetWindowInfoResult
      local result = {
        tabpage = tabpage,
        winid = winid,
        bufnr = bufnr,
        bufname = bufname,
      }

      return result
    end
  end

  return nil
end

--- @param path string
function mod.go_to_file_or_open(path)
  local window_id = mod.get_window_info_for_file(path)

  if window_id then
    vim.api.nvim_set_current_win(window_id.winid)
    -- TODO Maybe just use `nvim_set_current_win`.
    -- vim.cmd(window_id.tabpagenr .. 'tabnext')
    -- vim.cmd(window_id.winnr .. 'wincmd w')
  else
    -- vim.cmd('tabnew')
    -- vim.defer_fn(function()
    --   vim.cmd('edit ' .. path)
    -- end, 10)
    vim.cmd('tabedit ' .. path)
  end
end

return mod
