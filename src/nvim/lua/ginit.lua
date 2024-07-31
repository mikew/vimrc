local vimrc = require('vimrc')

local vim_ui = vimrc.determine_ui()
local vim_os = vimrc.determine_os()

local client_lookups = {
  vim_ui .. '/' .. vim_os,
  vim_ui,
  vim_os,
}

function get_value_or_star(table, keys)
  for _, value in ipairs(keys) do
    if table[value] then
      return table[value]
    end
  end

  return table['*']
end

local font_name = get_value_or_star({
  ['*'] = 'Iosevka Custom Slab',
}, client_lookups)

local font_size = get_value_or_star({
  ['*'] = 13,
}, client_lookups)

local linespace = get_value_or_star({
  ['*'] = 1,
}, client_lookups)

if vim_ui == 'nvim-qt' then
  vim.cmd(string.format('GuiFont %s:h%s', font_name, font_size))
  vim.cmd(string.format('GuiLinespace %s', linespace))

  if vim_os == 'macos' then
    -- Save.
    vim.keymap.set('n', '<D-s>', ':w<CR>')
    vim.keymap.set('i', '<D-s>', '<C-o>:w<CR>')
    vim.keymap.set('x', '<D-s>', '<Esc>:w<CR>gv')

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
    vim.keymap.set('n', '<D-n>', ':tabnew<CR>')
    -- Intentionally leave insert mode due to switching buffers.
    vim.keymap.set('i', '<D-n>', '<Esc>:tabnew<CR>')

    -- Tab navigation.
    vim.keymap.set('n', '<S-D-]>', ':tabnext<CR>')
    -- Intentionally leave insert mode due to switching buffers.
    vim.keymap.set('i', '<S-D-]>', '<Esc>:tabnext<CR>')
    vim.keymap.set('n', '<S-D-[>', ':tabprevious<CR>')
    -- Intentionally leave insert mode due to switching buffers.
    vim.keymap.set('i', '<S-D-[>', '<Esc>:tabprevious<CR>')

    -- Close Tab.
    vim.keymap.set('n', '<D-w>', ':tabclose<CR>')
    -- Intentionally leave insert mode due to switching buffers.
    vim.keymap.set('i', '<D-w>', '<Esc>:tabclose<CR>')

    -- Close Window.
    vim.keymap.set('n', '<D-W>', ':qa<CR>')
    vim.keymap.set('i', '<D-W>', '<Esc>:qa<CR>')

    -- Close all but current.
    -- TODO Doesn't seem to work in nvim-qt, could be macos characters?
    -- vim.keymap.set('n', '<M-D-w>', ':tabonly<CR>')
    -- vim.keymap.set('i', '<M-D-w>', '<C-o>:tabonly<CR>')

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
  end
end
