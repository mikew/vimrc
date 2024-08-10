--- @class LegacyDrawerCreateOptions
--- @field buf_name_prefix string
--- @field position 'left' | 'right' | 'top' | 'bottom'
--- @field on_will_create_buffer? fun(bufname: string): nil
--- @field on_did_open_drawer? fun(bufname: string): nil
--- @field on_did_open_split? fun(): nil
--- @field size integer

--- @type LegacyDrawerInstance[]
local instances = {}

--- @param opts LegacyDrawerCreateOptions
local function create(opts)
  --- @class LegacyDrawerState
  local state = {
    last_size = opts.size,
    was_open_before_tabchange = false,
    buffers = {},
    previous_buffer = '',
    counter = 0,
  }

  --- @class LegacyDrawerInstance
  local instance = {
    state = state,
    opts = opts,
  }

  function instance.toggle()
    if instance.is_open() then
      instance.close()
    else
      instance.open_most_recent()
    end
  end

  function instance.focus_or_toggle()
    if instance.is_open() then
      if instance.is_focused() then
        instance.close()
      else
        instance.focus()
      end
    else
      instance.open_most_recent()
    end
  end

  function instance.open_most_recent()
    instance.open_and_focus_split()

    local bufname = instance.state.previous_buffer
    if bufname == '' then
      bufname = instance.next_buf_name()
    end

    instance.edit_existing(bufname)
  end

  function instance.create_new()
    instance.open_and_focus_split()

    -- TODO This needs to happen in case the split is already open when
    -- CreateNew is called.
    vim.cmd('enew')

    instance.edit_existing(instance.next_buf_name())
  end

  function instance.next_buf_name()
    local index = instance.state.counter + 1
    instance.state.counter = index

    return instance.opts.buf_name_prefix .. index
  end

  function instance.open_and_focus_split()
    if instance.is_open() then
      instance.focus()
      instance.restore_size()

      return
    end

    -- TODO
    -- execute self.Look() . ' new'
    local cmd = ''
    if instance.opts.position == 'left' then
      cmd = 'topleft vertical'
    elseif instance.opts.position == 'right' then
      cmd = 'botright vertical'
    elseif instance.opts.position == 'top' then
      cmd = 'topleft'
    elseif instance.opts.position == 'bottom' then
      cmd = 'botright'
    end

    vim.cmd(cmd .. ' new')

    if instance.opts.on_did_open_split ~= nil then
      instance.opts.on_did_open_split()
    end
  end

  function instance.edit_existing(bufname)
    if vim.fn.bufnr(bufname) == -1 then
      if instance.opts.on_will_create_buffer ~= nil then
        instance.opts.on_will_create_buffer(bufname)
      end

      vim.cmd('file ' .. bufname)
    else
      vim.cmd('buffer ' .. bufname)
    end

    -- TODO
    -- setlocal bufhidden=hide
    -- setlocal nobuflisted
    -- setlocal winfixwidth
    -- setlocal winfixheight
    -- setlocal noequalalways

    instance.state.previous_buffer = bufname
    instance.register_buffer(bufname)

    if vim.t._drawer_cache == nil then
      vim.t._drawer_cache = {}
    end
    vim.t._drawer_cache[instance.opts.buf_name_prefix] = bufname

    if instance.opts.on_did_open_drawer ~= nil then
      instance.opts.on_did_open_drawer(bufname)
    end
  end

  function instance.register_buffer(bufname)
    if not vim.list_contains(state.buffers, bufname) then
      table.insert(state.buffers, bufname)
    end
  end

  function instance.close()
    instance.state.was_open_before_tabchange = false

    if not instance.is_open() then
      return
    end

    instance.focus()
    instance.store_size()
    vim.cmd('q')
  end

  function instance.is_open()
    return instance.get_win_num() ~= -1
  end

  function instance.get_win_num()
    -- if vim.t._drawer_cache ~= nil then
    --   return vim.fn.bufwinnr(vim.t._drawer_cache[instance.opts.buf_name_prefix])
    -- end

    for _, w in ipairs(vim.fn.range(1, vim.fn.winnr('$'))) do
      if instance.is_buffer(vim.fn.bufname(vim.fn.winbufnr(w))) then
        return w
      end
    end

    return -1
  end

  function instance.is_buffer(bufname)
    return vim.fn.match(bufname, instance.opts.buf_name_prefix) == 0
  end

  function instance.focus()
    if instance.is_open() then
      -- wincmd w seems to focus the wrong window if this is called from the
      -- terminal itself.
      -- TODO this may need to actually determine if called from a terminal, not
      -- just a quick_terminal_, if we want better integration with plain ol'
      -- terminals.
      if instance.is_focused() then
        return
      end

      vim.cmd(instance.get_win_num() .. 'wincmd w')
    end
  end

  function instance.is_focused()
    return instance.is_buffer(vim.fn.bufname())
  end

  function instance.store_size()
    instance.state.last_size = instance.get_size()
  end

  function instance.restore_size()
    local command = 'resize'

    if
      instance.opts.position == 'left' or instance.opts.position == 'right'
    then
      command = 'vertical resize'
    end

    vim.cmd(command .. ' ' .. instance.get_size())
  end

  function instance.get_size()
    local size = vim.fn.winheight(0)

    if
      instance.opts.position == 'left' or instance.opts.position == 'right'
    then
      size = vim.fn.winwidth(0)
    end

    return size
  end

  table.insert(instances, instance)

  return instance
end

return {
  create = create,
}
