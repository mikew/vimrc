local vimrc = require('vimrc')

local M = {}

---@enum (key) snacks.picker.EditCmd
local edit_cmd = {
  edit = 'buffer',
  split = 'sbuffer',
  vsplit = 'vert sbuffer',
  tab = 'tab sbuffer',
  drop = 'drop',
  tabdrop = 'tab drop',
}

--- @param picker snacks.Picker
--- @param _ unknown
--- @param action snacks.picker.jump.Action
local function snacks_default_jump_action(picker, _, action)
  local items = picker:selected({ fallback = true })

  local win = vim.api.nvim_get_current_win()

  local current_buf = vim.api.nvim_get_current_buf()

  local cmd = edit_cmd[action.cmd] or 'buffer'

  if cmd:find('drop') then
    local drop = {} ---@type string[]
    for _, item in ipairs(items) do
      local path = item.buf and vim.api.nvim_buf_get_name(item.buf)
        or Snacks.picker.util.path(item)
      if not path then
        Snacks.notify.error(
          'Either item.buf or item.file is required',
          { title = 'Snacks Picker' }
        )
        return
      end
      drop[#drop + 1] = vim.fn.fnameescape(path)
    end
    vim.cmd(cmd .. ' ' .. table.concat(drop, ' '))
  else
    for i, item in ipairs(items) do
      -- load the buffer
      local buf = item.buf ---@type number
      if not buf then
        local path = assert(
          Snacks.picker.util.path(item),
          'Either item.buf or item.file is required'
        )
        buf = vim.fn.bufadd(path)
      end
      vim.bo[buf].buflisted = true

      -- use an existing window if possible
      if
        cmd == 'buffer'
        and #items == 1
        and picker.opts.jump.reuse_win
        and buf ~= current_buf
      then
        for _, w in ipairs(vim.fn.win_findbuf(buf)) do
          if vim.api.nvim_win_get_config(w).relative == '' then
            win = w
            vim.api.nvim_set_current_win(win)
            break
          end
        end
      end

      -- open the first buffer
      if i == 1 then
        vim.cmd(('%s %d'):format(cmd, buf))
        win = vim.api.nvim_get_current_win()
      end
    end
  end

  -- set the cursor
  local item = items[1]
  local pos = item.pos
  if picker.opts.jump.match then
    pos = picker.matcher:bufpos(vim.api.nvim_get_current_buf(), item) or pos
  end
  if pos and pos[1] > 0 then
    vim.api.nvim_win_set_cursor(win, { pos[1], pos[2] })
    vim.cmd('norm! zzzv')
  elseif item.search then
    vim.cmd(item.search)
    vim.cmd('noh')
  end
end

-- https://github.com/folke/snacks.nvim/blob/454ba02d69347c0735044f159b95d2495fc79a73/lua/snacks/picker/actions.lua#L29
--- @param picker snacks.Picker
--- @param _ unknown
--- @param action snacks.picker.jump.Action
function M.jump(picker, _, action)
  -- if we're still in insert mode, stop it and schedule
  -- it to prevent issues with cursor position
  if vim.fn.mode():sub(1, 1) == 'i' then
    vim.cmd.stopinsert()
    vim.schedule(function()
      M.jump(picker, _, action)
    end)
    return
  end

  local items = picker:selected({ fallback = true })

  if picker.opts.jump.close then
    picker:close()
  else
    vim.api.nvim_set_current_win(picker.main)
  end

  if #items == 0 then
    return
  end

  local win = vim.api.nvim_get_current_win()

  local current_buf = vim.api.nvim_get_current_buf()
  local current_empty = vim.bo[current_buf].buftype == ''
    and vim.bo[current_buf].filetype == ''
    and vim.api.nvim_buf_line_count(current_buf) == 1
    and vim.api.nvim_buf_get_lines(current_buf, 0, -1, false)[1] == ''
    and vim.api.nvim_buf_get_name(current_buf) == ''

  if not current_empty then
    -- save position in jump list
    if picker.opts.jump.jumplist then
      vim.api.nvim_win_call(win, function()
        vim.cmd("normal! m'")
      end)
    end

    -- save position in tag stack
    if picker.opts.jump.tagstack then
      local from = vim.fn.getpos('.')
      from[1] = current_buf
      local tagstack = { { tagname = vim.fn.expand('<cword>'), from = from } }
      vim.fn.settagstack(vim.fn.win_getid(win), { items = tagstack }, 't')
    end
  end

  if action.cmd == 'split' then
    snacks_default_jump_action(picker, _, action)
  elseif action.cmd == 'vsplit' then
    snacks_default_jump_action(picker, _, action)
  else
    for _, item in ipairs(items) do
      vimrc.go_to_file_or_open(item.file, item.pos)
    end
  end

  -- HACK: this should fix folds
  if vim.wo.foldmethod == 'expr' then
    vim.schedule(function()
      vim.opt.foldmethod = 'expr'
    end)
  end

  if current_empty and vim.api.nvim_buf_is_valid(current_buf) then
    local w = vim.fn.win_findbuf(current_buf)
    if #w == 0 then
      vim.api.nvim_buf_delete(current_buf, { force = true })
    end
  end
end

local snacks_picker_actions = require('snacks.picker.actions')
snacks_picker_actions.jump = M.jump
