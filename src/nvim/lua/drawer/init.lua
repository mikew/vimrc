--- @class CreateDrawerOptions
--- @field bufname_prefix string
--- @field size integer
--- @field position 'left' | 'right' | 'top' | 'bottom'
---
--- @field on_will_create_buffer? fun(bufname: string): nil
--- @field on_did_open_buffer? fun(bufname: string): nil
---
--- @field on_will_open_split? fun(bufname: string): nil
--- @field on_did_open_split? fun(bufname: string): nil
---
--- @field on_will_close? fun(): nil
--- @field on_did_close? fun(): nil

--- @class DrawerState
--- @field is_open boolean
--- @field size integer
--- @field previous_bufname string
--- @field count integer

--- @type DrawerInstance[]
local instances = {}

--- @return integer[]
local function get_windows_in_tab()
  local tabinfo = vim.fn.gettabinfo(vim.fn.tabpagenr())[1]

  if tabinfo == nil then
    return {}
  end

  return tabinfo.windows
end

--- @param opts CreateDrawerOptions
local function create_drawer(opts)
  --- @class DrawerInstance
  local instance = {
    opts = opts,

    --- @type DrawerState
    state = {
      is_open = false,
      size = opts.size,
      previous_bufname = '',
      count = 0,
    },
  }

  --- @param callback_name string
  local function try_callback(callback_name, ...)
    if instance.opts[callback_name] then
      instance.opts[callback_name](...)
    end
  end

  --- @class DrawerOpenOptions
  --- @field focus? boolean
  --- @field mode? 'previous_or_new' | 'new'

  --- @param opts? DrawerOpenOptions
  function instance.open(opts)
    opts = vim.tbl_extend(
      'force',
      { focus = false, mode = 'previous_or_new' },
      opts or {}
    )

    if instance.state.is_open then
      return
    end

    local previous_buffer_exists = instance.state.previous_bufname ~= ''
        and vim.fn.bufnr(instance.state.previous_bufname) ~= -1

    local bufname = instance.state.previous_bufname
    if not previous_buffer_exists then
      instance.state.count = instance.state.count + 1
      bufname = instance.opts.bufname_prefix .. instance.state.count
    end

    instance.state.is_open = true

    local winnr = instance.get_winnr()

    if winnr == -1 then
      local cmd = ''
      if instance.opts.position == 'left' then
        cmd = 'topleft vertical '
      elseif instance.opts.position == 'right' then
        cmd = 'botright vertical '
      elseif instance.opts.position == 'top' then
        cmd = 'topleft '
      elseif instance.opts.position == 'bottom' then
        cmd = 'botright '
      end

      try_callback('on_will_open_split', bufname)

      vim.cmd(cmd .. instance.state.size .. 'new')

      try_callback('on_did_open_split', bufname)
    else
      vim.cmd(winnr .. 'wincmd w')
    end

    instance.switch_window_to_buffer(bufname)

    if not opts.focus then
      vim.cmd('wincmd p')
    end
  end

  --- @param bufname string
  function instance.switch_window_to_buffer(bufname)
    local bufnr = vim.fn.bufnr(bufname)

    if bufnr == -1 then
      try_callback('on_will_create_buffer', bufname)

      vim.cmd('file ' .. bufname)
    else
      vim.cmd('buffer ' .. bufname)
    end

    vim.opt_local.bufhidden = 'hide'
    vim.opt_local.buflisted = false

    vim.opt_local.equalalways = false
    if
        instance.opts.position == 'left' or instance.opts.position == 'right'
    then
      vim.opt_local.winfixwidth = true
      vim.opt_local.winfixheight = false
    else
      vim.opt_local.winfixwidth = false
      vim.opt_local.winfixheight = true
    end

    instance.state.previous_bufname = bufname

    try_callback('on_did_open_buffer', bufname)
  end

  --- @class DrawerCloseOptions
  --- @field save_size? boolean

  --- @param opts? DrawerCloseOptions
  function instance.close(opts)
    opts = vim.tbl_extend('force', { save_size = true }, opts or {})

    try_callback('on_will_close')

    instance.state.is_open = false

    local winnr = instance.get_winnr()

    if winnr ~= -1 then
      if opts.save_size then
        instance.state.size = instance.get_size()
      end
    end

    instance.focus_and_return(function()
      vim.cmd('close')
      try_callback('on_did_close')
    end)
  end

  --- @class DrawerToggleOptions
  --- @field open? DrawerOpenOptions

  --- @param opts? DrawerToggleOptions
  function instance.toggle(opts)
    opts = vim.tbl_extend('force', { open = nil }, opts or {})

    if instance.state.is_open then
      instance.close({ save_size = true })
    else
      instance.open(opts.open)
    end
  end

  function instance.focus_or_toggle()
    local winnr = instance.get_winnr()

    if winnr == -1 then
      instance.open({ focus = true })
    else
      if instance.is_foucsed() then
        instance.close({ save_size = true })
      else
        instance.focus()
      end
    end
  end

  function instance.get_winnr()
    for _, w in ipairs(vim.fn.range(1, vim.fn.winnr('$'))) do
      if instance.is_buffer(vim.fn.bufname(vim.fn.winbufnr(w))) then
        return w
      end
    end

    return -1
  end

  function instance.focus()
    local winnr = instance.get_winnr()

    if winnr == -1 then
      return
    end

    vim.cmd(winnr .. 'wincmd w')
  end

  function instance.is_foucsed()
    local winnr = instance.get_winnr()

    if winnr == -1 then
      return false
    end

    return vim.fn.winnr() == winnr
  end

  --- @param callback fun()
  function instance.focus_and_return(callback)
    local winnr = instance.get_winnr()

    if winnr == -1 then
      return
    end

    instance.focus()
    callback()
    vim.cmd('wincmd p')
  end

  function instance.get_size()
    local winnr = instance.get_winnr()

    if winnr == -1 then
      return 0
    end

    local size = 0

    instance.focus_and_return(function()
      size = vim.fn.winheight(0)

      if
          instance.opts.position == 'left' or instance.opts.position == 'right'
      then
        size = vim.fn.winwidth(0)
      end
    end)

    return size
  end

  --- @param bufname string
  function instance.is_buffer(bufname)
    return string.find(bufname, instance.opts.bufname_prefix) ~= nil
  end

  table.insert(instances, instance)

  return instance
end

vim.api.nvim_create_autocmd('TabEnter', {
  desc = 'nvim-drawer: Restore drawers',
  callback = function()
    for _, instance in ipairs(instances) do
      if instance.state.is_open then
        instance.close({ save_size = false })
        instance.open({ focus = false })

        instance.focus_and_return(function()
          local cmd = ''
          if
              instance.opts.position == 'left'
              or instance.opts.position == 'right'
          then
            cmd = 'vertical resize '
          else
            cmd = 'resize '
          end

          vim.cmd(cmd .. instance.state.size)
        end)
      else
        instance.close({ save_size = false })
      end
    end
  end,
})

vim.api.nvim_create_autocmd('TabLeave', {
  desc = 'nvim-drawer: Save drawer sizes',
  callback = function()
    for _, instance in ipairs(instances) do
      if instance.state.is_open then
        instance.state.size = instance.get_size()
      end
    end
  end,
})

vim.api.nvim_create_autocmd('WinClosed', {
  desc = 'nvim-drawer: Close tab when all non-drawers are closed',
  callback = function(event)
    --- @type integer
    --- @diagnostic disable-next-line: assign-type-mismatch
    local closing_window_id = tonumber(event.match)

    local closing_window_buffer =
        vim.fn.bufname(vim.fn.winbufnr(closing_window_id))
    --- @type DrawerInstance | nil
    local closing_window_instance = nil

    for _, instance in ipairs(instances) do
      if instance.is_buffer(closing_window_buffer) then
        closing_window_instance = instance
        break
      end
    end

    if closing_window_instance == nil then
      local windows_in_tab_without_closing = vim.tbl_filter(function(winid)
        return winid ~= closing_window_id
      end, get_windows_in_tab())

      local num_drawers_in_tab = 0
      for _, winid in ipairs(get_windows_in_tab()) do
        if winid ~= closing_window_id then
          for _, instance in ipairs(instances) do
            if instance.is_buffer(vim.fn.bufname(vim.fn.winbufnr(winid))) then
              num_drawers_in_tab = num_drawers_in_tab + 1
              break
            end
          end
        end
      end

      if num_drawers_in_tab == #windows_in_tab_without_closing then
        if vim.fn.tabpagenr('$') > 1 then
          vim.cmd('tabclose')
        else
          vim.cmd('qa')
        end
      end
    else
      closing_window_instance.close({ save_size = false })
    end
  end,
})

return {
  create_drawer = create_drawer,
}
