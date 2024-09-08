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
  local window_info = mod.get_window_info_for_file(path)

  if window_info then
    vim.api.nvim_set_current_win(window_info.winid)
  else
    local first_window = vim.api.nvim_tabpage_list_wins(0)[1] or -1

    --- @param path string
    local function tabedit(path)
      vim.cmd('tabedit ' .. path)
    end

    if first_window == -1 then
      tabedit(path)
    end

    local bufnr = vim.api.nvim_win_get_buf(first_window)
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    local buftype = vim.api.nvim_buf_get_option(bufnr, 'buftype')
    local is_modified = vim.api.nvim_buf_get_option(bufnr, 'modified')

    local is_first_window_empty = bufname == ''
      and (buftype == '' or buftype == 'nofile')
      and not is_modified

    if is_first_window_empty then
      vim.api.nvim_win_call(first_window, function()
        vim.cmd('edit ' .. path)
      end)

      vim.api.nvim_set_current_win(first_window)
    else
      tabedit(path)
    end
  end
end

return mod
