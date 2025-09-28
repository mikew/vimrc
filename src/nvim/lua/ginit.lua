local vimrc = require('vimrc')
local map = vimrc.keymap

local client_lookups = {
  vimrc.context.ui .. '/' .. vimrc.context.os,
  vimrc.context.ui,
  vimrc.context.os,
}

local function get_value_or_star(table, keys)
  for _, value in ipairs(keys) do
    if table[value] ~= nil then
      return table[value]
    end
  end

  return table['*']
end

local font_name = get_value_or_star({
  ['*'] = 'Iosevka Custom Slab',
}, client_lookups)

local font_size = get_value_or_star({
  ['macos'] = 13,
  ['*'] = 10,
}, client_lookups)

local linespace = get_value_or_star({
  ['*'] = 0,
}, client_lookups)

if vimrc.context.ui == 'nvim-qt' then
  pcall(vim.cmd, string.format('GuiFont! %s:h%s', font_name, font_size))
  pcall(vim.cmd, string.format('GuiLinespace %s', linespace))
  pcall(vim.fn.GuiClipboard)
else
  pcall(function()
    vim.opt.guifont = string.format('%s:h%s', font_name, font_size)
  end)
  pcall(function()
    vim.opt.guilinespace = linespace
  end)
end

if vimrc.context.os == 'macos' then
  -- Save.
  map('Save', '<D-s>', 'n', '<Cmd>w<CR>')
  map('Save', '<D-s>', 'i', '<C-o><Cmd>w<CR>')
  map('Save', '<D-s>', 'x', '<Esc><Cmd>w<CR>gv')

  -- Select All.
  map('Select All', '<D-a>', 'n', 'ggVG')
  -- <Esc> is fine here because it's going to lose their cursor position
  -- anyways.
  map('Select All', '<D-a>', 'i', '<Esc>ggVG')

  -- Undo.
  map('Undo', '<D-z>', 'n', 'u')
  map('Undo', '<D-z>', 'i', '<C-o>u')

  -- Redo.
  map('Redo', '<D-Z>', 'n', '<C-R>')
  map('Redo', '<D-Z>', 'i', '<C-o><C-R>')

  -- Command+Arrow movement.
  map('Go to beginning of line', '<D-Left>', 'n', '^')
  map('Go to beginning of line', '<D-Left>', 'i', '<Esc>I')
  map('Go to end of line', '<D-Right>', 'n', '$')
  map('Go to end of line', '<D-Right>', 'i', '<Esc>A')
  map('Go to beginning of file', '<D-Up>', 'n', 'gg^')
  map('Go to beginning of file', '<D-Up>', 'i', '<Esc>ggI')
  map('Go to end of file', '<D-Down>', 'n', 'G$')
  map('Go to end of file', '<D-Down>', 'i', '<Esc>G$a')

  -- Alt+Arrow movement.
  map('Move word backward', '<M-Left>', 'n', 'b')
  map('Move word backward', '<M-Left>', 'i', '<C-o>b')
  map('Move word forward', '<M-Right>', 'n', 'w')
  map('Move word forward', '<M-Right>', 'i', '<C-o>w')

  -- New Tab.
  map('New tab', '<D-n>', 'n', '<Cmd>tabnew<CR>')
  -- Intentionally leave insert mode due to switching buffers.
  map('New tab', '<D-n>', 'i', '<Esc><Cmd>tabnew<CR>')

  -- Tab navigation.
  map('Next tab', '<S-D-]>', 'n', '<Cmd>tabnext<CR>')
  map('Next tab', '<D-}>', 'n', '<Cmd>tabnext<CR>')
  -- Intentionally leave insert mode due to switching buffers.
  map('Next tab', '<S-D-]>', 'i', '<Esc><Cmd>tabnext<CR>')
  map('Next tab', '<D-}>', 'i', '<Esc><Cmd>tabnext<CR>')
  map('Previous tab', '<S-D-[>', 'n', '<Cmd>tabprevious<CR>')
  map('Previous tab', '<D-{>', 'n', '<Cmd>tabprevious<CR>')
  -- Intentionally leave insert mode due to switching buffers.
  map('Previous tab', '<S-D-[>', 'i', '<Esc><Cmd>tabprevious<CR>')
  map('Previous tab', '<D-{>', 'i', '<Esc><Cmd>tabprevious<CR>')

  -- Close Tab.
  map('Close tab', '<D-w>', 'n', '<Cmd>tabclose<CR>')
  -- Intentionally leave insert mode due to switching buffers.
  map('Close tab', '<D-w>', 'i', '<Esc><Cmd>tabclose<CR>')

  -- Close Window.
  map('Close window', '<D-W>', 'n', '<Cmd>qa<CR>')
  map('Close window', '<D-W>', 'i', '<Esc><Cmd>qa<CR>')

  -- Close all but current.
  -- TODO Doesn't seem to work in nvim-qt, could be macos characters?
  -- map('TODO', '<M-D-w>', 'n', '<Cmd>tabonly<CR>')
  -- map('TODO', '<M-D-w>', 'i', '<C-o><Cmd>tabonly<CR>')

  -- Cut.
  map('Cut', '<D-x>', 'x', '"+x')

  -- Copy.
  map('Copy', '<D-c>', 'x', '"+y')

  -- Paste.
  map('Paste', '<D-v>', 'n', '"+gP')
  map('Paste', '<D-v>', 'i', [[<C-\><C-o>"+gP]])
  map('Paste', '<D-v>', 'c', '<C-r>+')
  map('Paste', '<D-v>', 't', [[<C-\><C-n>"+pi]], { noremap = true, silent = true })

  -- Indent / outdent.
  map('Outdent', '<D-[>', 'n', '<<')
  map('Indent', '<D-]>', 'n', '>>')
  map('Outdent', '<D-[>', 'i', '<C-o><<')
  map('Indent', '<D-]>', 'i', '<C-o>>>')
  map('Outdent', '<D-[>', 'v', '<gv')
  map('Indent', '<D-]>', 'v', '>gv')
elseif vimrc.context.os == 'linux' then
  -- Save.
  map('Save', '<C-s>', 'n', '<Cmd>w<CR>')
  map('Save', '<C-s>', 'i', '<C-o><Cmd>w<CR>')
  map('Save', '<C-s>', 'x', '<Esc><Cmd>w<CR>gv')

  -- Select All.
  map('Select all', '<C-S-A>', 'n', 'ggVG')
  -- <Esc> is fine here because it's going to lose their cursor position
  -- anyways.
  map('Select all', '<C-a>', 'i', '<Esc>ggVG')

  -- Undo.
  map('Undo', '<C-z>', 'n', 'u')
  map('Undo', '<C-z>', 'i', '<C-o>u')

  -- Redo.
  map('Redo', '<C-Z>', 'n', '<C-R>')
  map('Redo', '<C-Z>', 'i', '<C-o><C-R>')

  -- Command+Arrow movement.
  map('Go to beginning of line', '<C-S-Left>', 'n', '^')
  map('Go to beginning of line', '<C-S-Left>', 'i', '<Esc>I')
  map('Go to end of line', '<C-S-Right>', 'n', '$')
  map('Go to end of line', '<C-S-Right>', 'i', '<Esc>A')
  map('Go to beginning of file', '<C-S-Up>', 'n', 'gg^')
  map('Go to beginning of file', '<C-S-Up>', 'i', '<Esc>ggI')
  map('Go to end of file', '<C-S-Down>', 'n', 'G$')
  map('Go to end of file', '<C-S-Down>', 'i', '<Esc>G$a')

  -- Alt+Arrow movement.
  map('Move word backward', '<M-Left>', 'n', 'b')
  map('Move word backward', '<M-Left>', 'i', '<C-o>b')
  map('Move word forward', '<M-Right>', 'n', 'w')
  map('Move word forward', '<M-Right>', 'i', '<C-o>w')

  -- New Tab.
  map('New tab', '<C-S-N>', 'n', '<Cmd>tabnew<CR>')
  -- Intentionally leave insert mode due to switching buffers.
  map('New tab', '<C-S-N>', 'i', '<Esc><Cmd>tabnew<CR>')

  -- Tab navigation.
  map('Next tab', '<C-S-]>', 'n', '<Cmd>tabnext<CR>')
  map('Next tab', '<C-}>', 'n', '<Cmd>tabnext<CR>')
  -- Intentionally leave insert mode due to switching buffers.
  map('Next tab', '<C-S-]>', 'i', '<Esc><Cmd>tabnext<CR>')
  map('Next tab', '<C-}>', 'i', '<Esc><Cmd>tabnext<CR>')
  map('Previous tab', '<C-S-[>', 'n', '<Cmd>tabprevious<CR>')
  map('Previous tab', '<C-{>', 'n', '<Cmd>tabprevious<CR>')
  -- Intentionally leave insert mode due to switching buffers.
  map('Previous tab', '<C-S-[>', 'i', '<Esc><Cmd>tabprevious<CR>')
  map('Previous tab', '<C-{>', 'i', '<Esc><Cmd>tabprevious<CR>')

  -- Close Tab.
  -- map('Close tab', '<D-w>', 'n', '<Cmd>tabclose<CR>')
  -- Intentionally leave insert mode due to switching buffers.
  -- map('Close tab', '<D-w>', 'i', '<Esc><Cmd>tabclose<CR>')

  -- Close Window.
  map('Close window', '<C-S-W>', 'n', '<Cmd>qa<CR>')
  map('Close window', '<C-S-W>', 'i', '<Esc><Cmd>qa<CR>')

  -- Close all but current.
  -- TODO Doesn't seem to work in nvim-qt, could be macos characters?
  map('Close other tabs', '<M-C-W>', 'n', '<Cmd>tabonly<CR>')
  map('Close other tabs', '<M-C-W>', 'i', '<C-o><Cmd>tabonly<CR>')

  -- Cut.
  map('Cut', '<C-x>', 'x', '"+x')

  -- Copy.
  map('Copy', '<C-c>', 'x', '"+y')

  -- Paste.
  map('Paste', '<C-S-V>', 'n', '"+gP')
  map('Paste', '<C-S-V>', 'i', [[<C-\><C-o>"+gP]])
  map('Paste', '<C-S-V>', 'c', '<C-r>+')
  map('Paste', '<C-S-V>', 't', [[<C-\><C-n>"+pi]], { noremap = true, silent = true })

  -- Indent / outdent.
  -- map('TODO', '<C-[>', 'n', '<<')
  -- map('TODO', '<C-]>', 'n', '>>')
  -- map('TODO', '<C-[>', 'i', '<C-o><<')
  -- map('TODO', '<C-]>', 'i', '<C-o>>>')
  -- map('TODO', '<C-[>', 'v', '<gv')
  -- map('TODO', '<C-]>', 'v', '>gv')
end
