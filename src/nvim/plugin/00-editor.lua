local vimrc = require('vimrc')
local vimrc_pack = require('vimrc_pack')
local symbols = require('symbols')
local vimrc_colors = require('vimrc_colors')

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

vimrc.on_ui_ready(function()
  if vimrc.context.ui == 'nvim-qt' then
    vimrc_pack.add({ { 'https://github.com/equalsraf/neovim-gui-shim' } })
  end
end)

-- Snacks is entirely too many things, split up across multiple features in
-- this repo. This initial bit just makes sure we don't enable any feature.
vimrc_pack.add({
  {
    'https://github.com/folke/snacks.nvim',
    data = {
      bigfile = { enabled = false },
      dashboard = { enabled = false },
      explorer = { enabled = false },
      indent = { enabled = false },
      input = { enabled = false },
      notifier = { enabled = false },
      picker = { enabled = false },
      quickfile = { enabled = false },
      scope = { enabled = false },
      scroll = { enabled = false },
      statuscolumn = { enabled = false },
      words = { enabled = false },
    },
    lazy = true,
    setup = function()
      require('snacks').setup(vimrc_pack.get_options_for('snacks.nvim'))
    end,
  },
})
vimrc_pack.add({
  {
    'https://github.com/kylechui/nvim-surround',
    version = vim.version.range('*'),
    lazy = true,
    setup = function()
      require('nvim-surround').setup()
    end,
  },
})

vimrc_pack.add({
  { 'https://github.com/michaeljsmith/vim-indent-object' },
})

-- Detect tabstop and shiftwidth automatically
vimrc_pack.add({ { 'https://github.com/tpope/vim-sleuth' } })

vimrc_pack.add({
  {
    'https://github.com/numToStr/Comment.nvim',
    lazy = true,
    setup = function()
      require('Comment').setup({
        ignore = '^(%s*)$',
      })
      vimrc.on_ui_ready(function()
        if vimrc.has_gui_running() and vimrc.context.os == 'macos' then
          map(
            'Toggle comment linewise',
            '<D-/>',
            'n',
            '<Plug>(comment_toggle_linewise_current)'
          )
          map(
            'Toggle comment linewise',
            '<D-/>',
            'i',
            '<C-o><Plug>(comment_toggle_linewise_current)'
          )
          map(
            'Toggle comment linewise',
            '<D-/>',
            'v',
            '<Plug>(comment_toggle_linewise_visual)gv'
          )
        else
          map(
            'Toggle comment linewise',
            '<C-/>',
            'n',
            '<Plug>(comment_toggle_linewise_current)'
          )
          map(
            'Toggle comment linewise',
            '<C-/>',
            'i',
            '<C-o><Plug>(comment_toggle_linewise_current)'
          )
          map(
            'Toggle comment linewise',
            '<C-/>',
            'v',
            '<Plug>(comment_toggle_linewise_visual)gv'
          )
        end
      end)
    end,
  },
})

vimrc_pack.add({
  {
    'https://github.com/windwp/nvim-autopairs',
    lazy = true,
    setup = function()
      require('nvim-autopairs').setup()
    end,
  },
})

vimrc_pack.add({
  {
    'https://github.com/nvimdev/indentmini.nvim',
    lazy = true,
    setup = function()
      require('indentmini').setup({
        char = symbols.indent.line,
      })
    end,
  },
})

vimrc_pack.add({
  {
    'https://github.com/RRethy/base16-nvim',
    setup = function()
  vim.cmd('colorscheme base16-oceanicnext')

  local function apply_additional_highlights()
    local theme = {}

    theme.background = vimrc_colors.get_hl_color('Normal', 'bg') or '#000000'
    theme.background_alt = vimrc_colors.darken(theme.background, 0.3)

    theme.text_primary = vimrc_colors.get_hl_color('Normal', 'fg') or '#ffffff'
    theme.text_quiet1 =
      vimrc_colors.mix(theme.text_primary, theme.background, 0.5)
    theme.text_quiet2 =
      vimrc_colors.mix(theme.text_primary, theme.background, 0.8)

    vim.api.nvim_set_hl(0, 'VimrcNormalNC', {
      fg = theme.text_quiet1,
      bg = theme.background_alt,
      force = true,
    })
    vim.api.nvim_set_hl(0, 'FloatBorder', {
      fg = theme.text_quiet2,
      force = true,
    })
    vim.api.nvim_set_hl(0, 'WinSeparator', {
      fg = theme.text_quiet2,
      force = true,
    })

    vim.api.nvim_set_hl(0, 'LineNr', {
      link = 'CursorLineNr',
      force = true,
    })
    vim.api.nvim_set_hl(0, 'FoldColumn', {
      link = 'CursorLineNr',
      force = true,
    })
    vim.api.nvim_set_hl(0, 'SignColumn', {
      link = 'CursorLineNr',
      force = true,
    })

    vim.api.nvim_set_hl(0, 'NvimTreeIndentMarker', {
      fg = theme.text_quiet2,
      force = true,
    })

    vim.api.nvim_set_hl(0, 'IndentLine', {
      fg = theme.text_quiet2,
      force = true,
    })
    vim.api.nvim_set_hl(0, 'IndentLineCurrent', {
      fg = theme.text_quiet1,
      force = true,
    })
  end

  vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
    callback = function()
      apply_additional_highlights()
    end,
  })

  apply_additional_highlights()
    end,
  },
})

vimrc_pack.add({
  {
    'https://github.com/RRethy/vim-illuminate',
    lazy = true,
    setup = function()
      require('illuminate').configure()
    end,
  },
})

vimrc_pack.add({
  {
    'https://github.com/luukvbaal/statuscol.nvim',
    setup = function()
  local builtin = require('statuscol.builtin')

  local ft_ignore = {
    'man',
    'help',
    'neo-tree',
    'starter',
    'TelescopePrompt',
    'Trouble',
    'NvimTree',
    'nvcheatsheet',
    'dapui_watches',
    'dap-repl',
    'dapui_console',
    'spectre_panel',
    'dapui_stacks',
    'dapui_breakpoints',
    'dapui_scopes',
    -- 'snacks_picker_list',
    -- 'snacks_picker_preview',
  }

  require('statuscol').setup({
    relculright = true,
    setopt = true,
    segments = {
      { text = { builtin.lnumfunc }, click = 'v:lua.ScLa' },

      {
        sign = {
          namespace = { 'diagnostic' },
          maxwidth = 1,
          colwidth = 1,
          auto = false,
        },
        click = 'v:lua.ScSa',
      },

      { text = { builtin.foldfunc }, click = 'v:lua.ScFa' },

      {
        sign = {
          namespace = { 'gitsign' },
          maxwidth = 1,
          colwidth = 1,
          auto = false,
        },
        click = 'v:lua.ScSa',
      },
    },
  })

  vim.api.nvim_create_autocmd('BufWinEnter', {
    callback = function()
      if vim.tbl_contains(ft_ignore, vim.bo.filetype) then
        -- Intentionally not using `vim.wo[event.winid]` here since it
        -- seems to mess up the options for windows opened from this
        -- window.
        vim.opt_local.statuscolumn = ''
        vim.opt_local.signcolumn = 'no'
        vim.opt_local.number = false
        vim.opt_local.foldcolumn = '0'
      end
    end,
  })
    end,
  },
})

vimrc_pack.add({
  {
    'https://github.com/andymass/vim-matchup',
    lazy = true,
    setup = function()
      require('match-up').setup({})
    end,
  },
})

vimrc_pack.add({
  {
    'https://github.com/nvim-lualine/lualine.nvim',
    setup = function()
  require('lualine').setup({
    options = {
      component_separators = { left = '|', right = '|' },
      section_separators = { left = '', right = '' },
    },

    sections = {
      lualine_a = { 'mode' },
      lualine_b = {
        'branch',
      },
      lualine_c = { 'filename' },

      lualine_x = { 'filetype' },
      lualine_y = {},
      lualine_z = { 'location' },
    },

    tabline = {
      lualine_a = {
        {
          'tabs',

          mode = 1,
          path = 0,
          max_length = function()
            return vim.o.columns
          end,

          --- @param fallback_name string
          --- @param fmt_context {
          --- buftype: string,
          --- current: boolean,
          --- file: string,
          --- filetype: string,
          --- first: boolean,
          --- last: boolean,
          --- options: table,
          --- tabId: integer,
          --- tabnr: integer,
          --- }
          fmt = function(fallback_name, fmt_context)
            local no_name = '[No Name]'

            local to_check = {
              -- Start with the focused window.
              vim.api.nvim_tabpage_get_win(fmt_context.tabId),
            }
            -- Then add all other windows in the tab.
            vim.list_extend(
              to_check,
              vim.api.nvim_tabpage_list_wins(fmt_context.tabId)
            )

            --- @param wininfo { bufnr: integer, winid: integer, bufname: string, buftype: string }
            local function should_skip(wininfo)
              if
                vim.tbl_contains(
                  { 'nofile', 'quickfix', 'help' },
                  wininfo.buftype
                )
              then
                return true
              end

              if vimrc_pack.has_plugin('nvim-drawer') then
                local drawer = require('nvim-drawer')

                if drawer.find_instance_for_winid(wininfo.winid) then
                  return true
                end
              end
            end

            for _, winid in ipairs(to_check) do
              local bufnr = vim.api.nvim_win_get_buf(winid)
              local bufname =
                vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':t')

              if bufname == '' then
                bufname = no_name
              end

              local wininfo = {
                bufnr = bufnr,
                winid = winid,
                bufname = bufname,
                buftype = vim.api.nvim_get_option_value('buftype', {
                  buf = bufnr,
                }),
              }

              if not should_skip(wininfo) then
                return wininfo.bufname
              end
            end

            return no_name
          end,
        },
      },
    },
  })
    end,
  },
})

vimrc_pack.add({
  { 'https://github.com/kevinhwang91/promise-async' },
  {
    'https://github.com/kevinhwang91/nvim-ufo',
    lazy = true,
    setup = function()
      require('ufo').setup({
        provider_selector = function(bufnr, filetype, buftype)
          return { 'treesitter', 'indent' }
        end,
      })
    end,
  },
})
