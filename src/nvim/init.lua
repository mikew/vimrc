local vimrc = require('vimrc')
local symbols = require('symbols')

local map = vimrc.keymap

for _, tool in ipairs({ 'node', 'python' }) do
  vimrc.prepend_mise_tool_path(tool)
end

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be
--  used)
--  Space as leader needs to be nooped before it will work.
map('Prepare leader', ' ', 'n', '<Nop>', { silent = true, remap = false })
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Case-insensitive searching UNLESS \C or one or more capital letters in the
-- search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Disable word wrap.
vim.wo.wrap = false
vim.wo.list = false

-- Use indent as default fold method.
vim.o.foldmethod = 'indent'
-- Don't fold by default.
vim.o.foldlevelstart = 100
vim.o.foldcolumn = '1'
vim.o.foldmarker = '#region,#endregion'

-- Indent / outdent.
map('Indent and reselect', '<', 'v', '<gv')
map('Outdent and reselect', '>', 'v', '>gv')

-- New line.
map('Insert new line below', '<D-CR>', 'i', '<C-o>o')

vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.expandtab = true

vim.o.termguicolors = true
vim.o.cmdheight = 0
require('vim._core.ui2').enable({
  enable = true,
})

vim.o.title = true
vim.o.titlestring = table.concat({
  '%t',
  '%{fnamemodify(getcwd(), ":t")}',
  '%{hostname()}',
}, ' - ')

-- Always show tab bar.
vim.o.showtabline = 2

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

-- Hide inline diagnostics.
vim.diagnostic.config({
  severity_sort = true,

  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = symbols.diagnostics.error,
      [vim.diagnostic.severity.WARN] = symbols.diagnostics.warn,
      [vim.diagnostic.severity.INFO] = symbols.diagnostics.info,
      [vim.diagnostic.severity.HINT] = symbols.diagnostics.hint,
    },
  },

  float = {
    border = symbols.border.nvim_style,
  },

  virtual_text = false,
  -- Display multiline diagnostics as virtual lines
  -- virtual_lines = true,
})
map(
  'Open diagnostic float',
  '<Leader>d',
  'n',
  ':lua vim.diagnostic.open_float()<CR>',
  { noremap = true, silent = true }
)

-- Hide intro message.
vim.opt.shortmess:append('I', 'l', 'm', 'r')

-- Make line numbers default
vim.o.number = true
vim.o.numberwidth = 4
-- You can also add relative line numbers, to help with jumping.
-- Experiment for yourself to see if you like it!
-- vim.o.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.o.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Keep signcolumn on by default
-- Stop gitsigns and diagnostics from clobbering each other.
vim.o.signcolumn = 'yes:2'

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
-- vim.o.scrolloff = 3
vim.o.sidescrolloff = 5
vim.o.mousescroll = 'ver:5,hor:5'

-- Keybinds to make split navigation easier.
-- Use CTRL+<hjkl> to switch between windows
-- See `:help wincmd` for a list of all window commands
map('Move focus to the left window', '<C-h>', 'n', '<C-w><C-h>')
map('Move focus to the right window', '<C-l>', 'n', '<C-w><C-l>')
map('Move focus to the lower window', '<C-j>', 'n', '<C-w><C-j>')
map('Move focus to the upper window', '<C-k>', 'n', '<C-w><C-k>')

-- Rulers.
vim.opt.colorcolumn = { 81, 121 }

-- Remove `~`.
vim.opt.fillchars = {
  eob = ' ',

  foldopen = symbols.generic.arrow_down,
  foldclose = symbols.generic.arrow_right_solid,
  fold = ' ',
  foldsep = ' ',
}

-- Only one statusline at the bottom of the window.
vim.o.laststatus = 3

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vimrc.create_augroup('kickstart-highlight-yank'),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Resize splits if window got resized
vim.api.nvim_create_autocmd({ 'VimResized' }, {
  group = vimrc.create_augroup('resize_splits'),
  callback = function()
    vimrc.better_tabdo(function()
      vim.cmd('tabdo wincmd =')
    end)
  end,
})

-- Fix conceallevel for json files
vim.api.nvim_create_autocmd({ 'FileType' }, {
  group = vimrc.create_augroup('json_conceal'),
  pattern = { 'json', 'jsonc', 'json5' },
  callback = function()
    vim.wo.conceallevel = 0
  end,
})

-- Auto create dir when saving a file, in case some intermediate directory
-- does not exist
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  group = vimrc.create_augroup('auto_create_dir'),
  callback = function(event)
    if event.match:match('^%w%w+:[\\/][\\/]') then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
  end,
})

-- Terminal annoyances.
-- https://github.com/neovim/neovim/issues/24093
map('Insert enter', '<S-Enter>', 't', '<Enter>')
map('Insert space', '<S-Space>', 't', '<Space>')
map('Insert backspace', '<S-BS>', 't', '<BS>')
vim.api.nvim_create_autocmd({
  -- 'TermOpen',
  'WinEnter',
}, { pattern = 'term://*', command = 'startinsert' })
vim.api.nvim_create_autocmd(
  { 'BufLeave' },
  { pattern = 'term://*', command = 'stopinsert' }
)
-- TODO Need to find a better combo as this delays Esc key presses.
map('Exit terminal mode', '<Esc><Esc>', 't', [[<C-\><C-n>]], { noremap = true })

-- Dim inactive windows.
vim.api.nvim_create_autocmd({
  -- Doesn't seem to trigger on startup.
  'WinEnter',
  'BufWinEnter',
}, {
  group = vimrc.create_augroup('dim_inactive_windows'),
  callback = function()
    vim.o.winhighlight = 'NormalNC:VimrcNormalNC'
  end,
})

---@param filename string
---@param line number?
---@param col number?
_G.nvrh_open_file_handler = function(filename, line, col)
  vimrc.go_to_file_or_open(filename, { line, col })
end

-- Save / restore folds & cursor.
vim.opt.viewoptions = {
  'folds',
  'cursor',
}
local view_group = vimrc.create_augroup('view_restore')
local ignore_ft = { 'gitcommit', 'gitrebase', 'hgcommit', 'svn', 'xxd' }
local ignore_bt = { 'terminal', 'nofile', 'quickfix', 'help' }

vim.api.nvim_create_autocmd('BufWinLeave', {
  group = view_group,
  pattern = '?*',
  callback = function()
    local ft = vim.bo.filetype
    local bt = vim.bo.buftype

    if vim.tbl_contains(ignore_ft, ft) or vim.tbl_contains(ignore_bt, bt) then
      return
    end

    vim.cmd('silent! mkview!')
  end,
})

vim.api.nvim_create_autocmd('BufWinEnter', {
  group = view_group,
  pattern = '?*',
  callback = function()
    local ft = vim.bo.filetype
    local bt = vim.bo.buftype

    if vim.tbl_contains(ignore_ft, ft) or vim.tbl_contains(ignore_bt, bt) then
      return
    end

    local cur = vim.api.nvim_win_get_cursor(0)
    if cur[1] > 1 or cur[2] > 0 then
      return
    end

    vim.cmd('silent! loadview')
  end,
})

vim.cmd('command! Q q')
vim.cmd('command! Qa qa')
vim.cmd('command! QA qa')

vim.api.nvim_create_user_command('BetterTabclose', function(args)
  vimrc.better_tabclose(tonumber(args.args))
end, { nargs = 1 })

vim.api.nvim_create_autocmd('WinClosed', {
  callback = function(event)
    local drawer = require('nvim-drawer')

    --- @type integer
    --- @diagnostic disable-next-line: assign-type-mismatch
    local closing_window_id = tonumber(event.match)
    if not vim.api.nvim_win_is_valid(closing_window_id) then
      return
    end

    local closing_instance = drawer.find_instance_for_winid(closing_window_id)

    if closing_instance then
      return
    end

    local bufnr_closed = vim.api.nvim_win_get_buf(closing_window_id)

    -- If the buffer is open in any other window, do nothing.
    for _, winid in ipairs(vim.api.nvim_list_wins()) do
      if winid ~= closing_window_id then
        local bufnr = vim.api.nvim_win_get_buf(winid)
        if bufnr == bufnr_closed then
          return
        end
      end
    end

    -- Otherwise delete the buffer.
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(bufnr_closed) then
        vim.api.nvim_buf_delete(bufnr_closed, { force = true })
      end
    end)
  end,
})

-- gui loading
--- @type table<integer, boolean>
local uis_already_handled = {}
vim.api.nvim_create_autocmd('UIEnter', {
  group = vimrc.create_augroup('detect_ui'),
  callback = function(event)
    local function try_latest_ui()
      -- For some reason `event.data` is nil.
      -- local chan = event.data.chan
      -- So instead loop through all the channels, finding the latest where
      -- `client.type` is `ui`.
      --- @type integer?
      local chan
      for _, c in pairs(vim.api.nvim_list_chans()) do
        if
          c.client
          and c.client.type == 'ui'
          and not uis_already_handled[c.id]
        then
          chan = c.id
        end
      end

      if not chan then
        vim.schedule(try_latest_ui)
        return
      end

      uis_already_handled[chan] = true

      local uienter_chan = vim.api.nvim_get_chan_info(chan)

      --- @type VimrcUiContext
      local ui_context = {
        ui = '',
        os = '',
        has_gui = false,
      }

      if uienter_chan.client then
        ui_context.ui = uienter_chan.client.name
      end

      -- If we're in an nvrh session we can get the client OS from the channel.
      if _G._nvrh then
        for _, c in pairs(vim.api.nvim_list_chans()) do
          if
            c.client
            and c.client.name == 'nvrh'
            and c.client.attributes
            and c.client.attributes.nvrh_assumed_ui_channel == tostring(chan)
          then
            local nvrh_client_os = c.client.attributes.nvrh_client_os
            if nvrh_client_os == 'darwin' then
              nvrh_client_os = 'macos'
            end
            ui_context.os = nvrh_client_os

            break
          end
        end
      else
        -- Or determine the OS ourselves.
        ui_context.os = vimrc.determine_os()
      end

      ui_context.has_gui = ui_context.ui ~= 'nvim-tui'

      vim.schedule(function()
        if ui_context.has_gui then
          require('ginit').setup(ui_context)
        end

        vimrc.run_ui_ready_callbacks(ui_context)
      end)
    end

    try_latest_ui()
  end,
})
