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
  local current_tab = vim.fn.tabpagenr()
  callback()
  vim.cmd('tabnext ' .. current_tab)
end

function mod.create_augroup(name, clear)
  clear = clear == nil and true or clear
  return vim.api.nvim_create_augroup('vimrc_' .. name, { clear = clear })
end

function mod.determine_os()
  local os = vim.loop.os_uname().sysname

  if os == 'Linux' then
    return 'linux'
  elseif os == 'Darwin' then
    return 'macos'
  elseif os == 'Windows' then
    return 'windows'
  end
end

return mod
