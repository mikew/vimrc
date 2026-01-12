local mod = {}

--- @class VimrcFeature
--- @field name string
--- @field plugins? LazySpec[]

--- @param fn fun(context: VimrcContext): VimrcFeature
--- @return fun(context: VimrcContext): VimrcFeature
function mod.make_setup(fn)
  --- @param context VimrcContext
  return function(context)
    local feature = fn(context)
    table.insert(context.features, feature.name)

    if feature.plugins then
      for _, plugin in ipairs(feature.plugins) do
        table.insert(context.plugins, plugin)
      end
    end

    return feature
  end
end

function mod.determine_ui()
  local force_ui = os.getenv('NVIM_FORCE_UI')
  if force_ui ~= nil then
    return force_ui
  end

  if vim.g.neovide then
    return 'neovide'
  end

  if vim.g.fvim_loaded then
    return 'fvim'
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

--- @param callback fun()
function mod.better_tabdo(callback)
  local current_tab = vim.api.nvim_tabpage_get_number(0)
  callback()
  vim.cmd('tabnext ' .. current_tab)
end

--- @param name string
--- @param clear? boolean
function mod.create_augroup(name, clear)
  clear = clear == nil and true or clear
  return vim.api.nvim_create_augroup('vimrc_' .. name, { clear = clear })
end

function mod.determine_os()
  local force_os = os.getenv('NVIM_FORCE_OS')
  if force_os ~= nil then
    return force_os
  end

  local os = vim.uv.os_uname().sysname

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
    local bufname_with_cwd = vim.api.nvim_buf_get_name(bufnr)
    local bufname = vim.fn.fnamemodify(bufname_with_cwd, ':.')

    if
      bufname == path
      or bufname == path_with_cwd
      or bufname_with_cwd == path
      or bufname_with_cwd == path_with_cwd
    then
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
--- @param pos? (integer | nil)[]
function mod.go_to_file_or_open(path, pos)
  local function go_to_pos()
    if pos and pos[1] and pos[2] then
      vim.schedule(function()
        vim.api.nvim_win_set_cursor(0, { pos[1], pos[2] })
        vim.cmd('norm! zzzv')
      end)
    end
  end

  local window_info = mod.get_window_info_for_file(path)

  if window_info then
    vim.api.nvim_set_current_win(window_info.winid)
    go_to_pos()
  else
    local first_window = vim.api.nvim_tabpage_list_wins(0)[1] or -1

    local function tabedit()
      vim.cmd('tabedit ' .. vim.fn.fnameescape(path))
      go_to_pos()
    end

    if first_window == -1 then
      tabedit()
      return
    end

    local bufnr = vim.api.nvim_win_get_buf(first_window)
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    local buftype = vim.api.nvim_get_option_value('buftype', { buf = bufnr })
    local is_modified =
      vim.api.nvim_get_option_value('modified', { buf = bufnr })

    local is_first_window_empty = bufname == ''
      and (buftype == '' or buftype == 'nofile')
      and not is_modified

    if is_first_window_empty then
      vim.api.nvim_win_call(first_window, function()
        vim.cmd('edit ' .. vim.fn.fnameescape(path))
        go_to_pos()
      end)

      vim.api.nvim_set_current_win(first_window)
    else
      tabedit()
    end
  end
end

--- @class VimrcContext
mod.context = {
  os = mod.determine_os(),
  ui = mod.determine_ui(),
  has_gui_running = mod.has_gui_running(),

  --- @type string[]
  features = {},
  --- @type LazySpec[]
  plugins = {},
}

--- @param name string
function mod.has_feature(name)
  return vim.list_contains(mod.context.features, name)
end

---@param desc string
---@param lhs string
---@param mode string|string[]
---@param rhs string|function
---@param opts? vim.keymap.set.Opts
function mod.keymap(desc, lhs, mode, rhs, opts)
  vim.keymap.set(
    mode,
    lhs,
    rhs,
    vim.tbl_extend('force', { desc = desc }, opts or {})
  )
end

vim.api.nvim_create_autocmd('WinClosed', {
  desc = 'nvim-drawer: Close tab when all non-drawers are closed',
  callback = function(event)
    local drawer = require('nvim-drawer')

    --- @type integer
    --- @diagnostic disable-next-line: assign-type-mismatch
    local closing_window_id = tonumber(event.match)
    local closing_instance = drawer.find_instance_for_winid(closing_window_id)

    if closing_instance then
      return
    end

    local bufnr_closed = vim.api.nvim_win_get_buf(closing_window_id)
    vim.api.nvim_buf_delete(bufnr_closed, {})
  end,
})

return mod
