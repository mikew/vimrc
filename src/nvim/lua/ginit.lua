local vimrc = require('vimrc')

local vim_ui = vimrc.determine_ui()
local vim_os = vimrc.determine_os()

local client_lookups = {
  vim_ui .. '/' .. vim_os,
  vim_ui,
  vim_os,
}

local function get_value_or_star(table, keys)
  for _, value in ipairs(keys) do
    if table[value] then
      return table[value]
    end
  end

  return table['*']
end

local font_name = get_value_or_star({
  ['*'] = 'Iosevka Custom Slab Terminal',
}, client_lookups)

local font_size = get_value_or_star({
  ['macos'] = 13,
  ['*'] = 10,
}, client_lookups)

local linespace = get_value_or_star({
  ['*'] = 1,
}, client_lookups)

if vim_ui == 'nvim-qt' then
  vim.cmd(string.format('GuiFont %s:h%s', font_name, font_size))
  vim.cmd(string.format('GuiLinespace %s', linespace))
else
  pcall(function()
    vim.opt.guifont = string.format('%s:h%s', font_name, font_size)
  end)
  pcall(function()
    vim.opt.guilinespace = linespace
  end)
end

if vim_os == 'macos' then
  -- Save.
  vim.keymap.set('n', '<D-s>', '<Cmd>w<CR>')
  vim.keymap.set('i', '<D-s>', '<C-o><Cmd>w<CR>')
  vim.keymap.set('x', '<D-s>', '<Esc><Cmd>w<CR>gv')

  -- Select All.
  vim.keymap.set('n', '<D-a>', 'ggVG')
  -- <Esc> is fine here because it's going to lose their cursor position
  -- anyways.
  vim.keymap.set('i', '<D-a>', '<Esc>ggVG')

  -- Undo.
  vim.keymap.set('n', '<D-z>', 'u')
  vim.keymap.set('i', '<D-z>', '<C-o>u')

  -- Redo.
  vim.keymap.set('n', '<D-Z>', '<C-R>')
  vim.keymap.set('i', '<D-Z>', '<C-o><C-R>')

  -- Command+Arrow movement.
  vim.keymap.set('n', '<D-Left>', '^')
  vim.keymap.set('i', '<D-Left>', '<Esc>I')
  vim.keymap.set('n', '<D-Right>', '$')
  vim.keymap.set('i', '<D-Right>', '<Esc>A')
  vim.keymap.set('n', '<D-Up>', 'gg^')
  vim.keymap.set('i', '<D-Up>', '<Esc>ggI')
  vim.keymap.set('n', '<D-Down>', 'G$')
  vim.keymap.set('i', '<D-Down>', '<Esc>G$a')

  -- Alt+Arrow movement.
  vim.keymap.set('n', '<M-Left>', 'b')
  vim.keymap.set('i', '<M-Left>', '<C-o>b')
  vim.keymap.set('n', '<M-Right>', 'w')
  vim.keymap.set('i', '<M-Right>', '<C-o>w')

  -- New Tab.
  vim.keymap.set('n', '<D-n>', '<Cmd>tabnew<CR>')
  -- Intentionally leave insert mode due to switching buffers.
  vim.keymap.set('i', '<D-n>', '<Esc><Cmd>tabnew<CR>')

  -- Tab navigation.
  vim.keymap.set('n', '<S-D-]>', '<Cmd>tabnext<CR>')
  vim.keymap.set('n', '<D-}>', '<Cmd>tabnext<CR>')
  -- Intentionally leave insert mode due to switching buffers.
  vim.keymap.set('i', '<S-D-]>', '<Esc><Cmd>tabnext<CR>')
  vim.keymap.set('i', '<D-}>', '<Esc><Cmd>tabnext<CR>')
  vim.keymap.set('n', '<S-D-[>', '<Cmd>tabprevious<CR>')
  vim.keymap.set('n', '<D-{>', '<Cmd>tabprevious<CR>')
  -- Intentionally leave insert mode due to switching buffers.
  vim.keymap.set('i', '<S-D-[>', '<Esc><Cmd>tabprevious<CR>')
  vim.keymap.set('i', '<D-{>', '<Esc><Cmd>tabprevious<CR>')

  -- Close Tab.
  vim.keymap.set('n', '<D-w>', '<Cmd>tabclose<CR>')
  -- Intentionally leave insert mode due to switching buffers.
  vim.keymap.set('i', '<D-w>', '<Esc><Cmd>tabclose<CR>')

  -- Close Window.
  vim.keymap.set('n', '<D-W>', '<Cmd>qa<CR>')
  vim.keymap.set('i', '<D-W>', '<Esc><Cmd>qa<CR>')

  -- Close all but current.
  -- TODO Doesn't seem to work in nvim-qt, could be macos characters?
  -- vim.keymap.set('n', '<M-D-w>', '<Cmd>tabonly<CR>')
  -- vim.keymap.set('i', '<M-D-w>', '<C-o><Cmd>tabonly<CR>')

  -- Cut.
  vim.keymap.set('x', '<D-x>', '"+x')

  -- Copy.
  vim.keymap.set('x', '<D-c>', '"+y')

  -- Paste.
  vim.keymap.set('n', '<D-v>', '"+P')
  -- vim.keymap.set('i', '<D-v>', '<C-r>+')
  vim.keymap.set('i', '<D-v>', '<C-o>"+P')
  vim.keymap.set('c', '<D-v>', '<C-r>+')

  -- Indent / outdent.
  vim.keymap.set('n', '<D-[>', '<<')
  vim.keymap.set('n', '<D-]>', '>>')
  vim.keymap.set('i', '<D-[>', '<C-o><<')
  vim.keymap.set('i', '<D-]>', '<C-o>>>')
  vim.keymap.set('v', '<D-[>', '<gv')
  vim.keymap.set('v', '<D-]>', '>gv')
elseif vim_os == 'linux' then
  -- Save.
  vim.keymap.set('n', '<C-s>', '<Cmd>w<CR>')
  vim.keymap.set('i', '<C-s>', '<C-o><Cmd>w<CR>')
  vim.keymap.set('x', '<C-s>', '<Esc><Cmd>w<CR>gv')

  -- Select All.
  vim.keymap.set('n', '<C-S-A>', 'ggVG')
  -- <Esc> is fine here because it's going to lose their cursor position
  -- anyways.
  vim.keymap.set('i', '<C-a>', '<Esc>ggVG')

  -- Undo.
  vim.keymap.set('n', '<C-z>', 'u')
  vim.keymap.set('i', '<C-z>', '<C-o>u')

  -- Redo.
  vim.keymap.set('n', '<C-Z>', '<C-R>')
  vim.keymap.set('i', '<C-Z>', '<C-o><C-R>')

  -- Command+Arrow movement.
  vim.keymap.set('n', '<C-S-Left>', '^')
  vim.keymap.set('i', '<C-S-Left>', '<Esc>I')
  vim.keymap.set('n', '<C-S-Right>', '$')
  vim.keymap.set('i', '<C-S-Right>', '<Esc>A')
  vim.keymap.set('n', '<C-S-Up>', 'gg^')
  vim.keymap.set('i', '<C-S-Up>', '<Esc>ggI')
  vim.keymap.set('n', '<C-S-Down>', 'G$')
  vim.keymap.set('i', '<C-S-Down>', '<Esc>G$a')

  -- Alt+Arrow movement.
  vim.keymap.set('n', '<M-Left>', 'b')
  vim.keymap.set('i', '<M-Left>', '<C-o>b')
  vim.keymap.set('n', '<M-Right>', 'w')
  vim.keymap.set('i', '<M-Right>', '<C-o>w')

  -- New Tab.
  vim.keymap.set('n', '<C-S-N>', '<Cmd>tabnew<CR>')
  -- Intentionally leave insert mode due to switching buffers.
  vim.keymap.set('i', '<C-S-N>', '<Esc><Cmd>tabnew<CR>')

  -- Tab navigation.
  vim.keymap.set('n', '<C-S-]>', '<Cmd>tabnext<CR>')
  vim.keymap.set('n', '<C-}>', '<Cmd>tabnext<CR>')
  -- Intentionally leave insert mode due to switching buffers.
  vim.keymap.set('i', '<C-S-]>', '<Esc><Cmd>tabnext<CR>')
  vim.keymap.set('i', '<C-}>', '<Esc><Cmd>tabnext<CR>')
  vim.keymap.set('n', '<C-S-[>', '<Cmd>tabprevious<CR>')
  vim.keymap.set('n', '<C-{>', '<Cmd>tabprevious<CR>')
  -- Intentionally leave insert mode due to switching buffers.
  vim.keymap.set('i', '<C-S-[>', '<Esc><Cmd>tabprevious<CR>')
  vim.keymap.set('i', '<C-{>', '<Esc><Cmd>tabprevious<CR>')

  -- Close Tab.
  -- vim.keymap.set('n', '<D-w>', '<Cmd>tabclose<CR>')
  -- Intentionally leave insert mode due to switching buffers.
  -- vim.keymap.set('i', '<D-w>', '<Esc><Cmd>tabclose<CR>')

  -- Close Window.
  vim.keymap.set('n', '<C-S-W>', '<Cmd>qa<CR>')
  vim.keymap.set('i', '<C-S-W>', '<Esc><Cmd>qa<CR>')

  -- Close all but current.
  -- TODO Doesn't seem to work in nvim-qt, could be macos characters?
  -- vim.keymap.set('n', '<M-D-w>', '<Cmd>tabonly<CR>')
  -- vim.keymap.set('i', '<M-D-w>', '<C-o><Cmd>tabonly<CR>')

  -- Cut.
  vim.keymap.set('x', '<C-x>', '"+x')

  -- Copy.
  vim.keymap.set('x', '<C-c>', '"+y')

  -- Paste.
  vim.keymap.set('n', '<C-S-V>', '"+P')
  -- vim.keymap.set('i', '<D-v>', '<C-r>+')
  vim.keymap.set('i', '<C-v>', '<C-o>"+P')
  vim.keymap.set('c', '<C-v>', '<C-r>+')

  -- Indent / outdent.
  vim.keymap.set('n', '<C-[>', '<<')
  vim.keymap.set('n', '<C-]>', '>>')
  vim.keymap.set('i', '<C-[>', '<C-o><<')
  vim.keymap.set('i', '<C-]>', '<C-o>>>')
  vim.keymap.set('v', '<C-[>', '<gv')
  vim.keymap.set('v', '<C-]>', '>gv')
end
