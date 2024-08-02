local vimrc = require('vimrc')
local symbols = require('symbols')

local vim_ui = vimrc.determine_ui()
local vim_os = vimrc.determine_os()
local has_gui_running = vimrc.has_gui_running()

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be
--  used)
vim.g.mapleader = '\\'
vim.g.maplocalleader = '\\'

-- Case-insensitive searching UNLESS \C or one or more capital letters in the
-- search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Disable word wrap.
vim.wo.wrap = false
vim.wo.list = false

-- Use indent as default fold method.
vim.opt.foldmethod = 'indent'
-- Don't fold by default.
vim.opt.foldlevelstart = 100

-- Indent / outdent.
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

if not vim.g.vscode then
  -- Always show tab bar.
  vim.opt.showtabline = 2

  -- Hide inline diagnostics.
  vim.diagnostic.config({
    virtual_text = false,
  })
  vim.api.nvim_set_keymap(
    'n',
    '<Leader>d',
    ':lua vim.diagnostic.open_float()<CR>',
    { noremap = true, silent = true }
  )

  -- Hide intro message.
  vim.opt.shortmess:append('I', 'l', 'm', 'r')

  -- TODO
  --   set undofile
  -- set undodir^=~/.cache/vim/undo//
  -- set backupdir=~/.cache/vim/backup//
  -- set directory=~/.cache/vim/swap//
  -- let g:netrw_home='~/.cache/vim'
  -- if !has('nvim')
  --   set viminfofile=~/.cache/vim/viminfo
  -- endif

  -- map Q <Nop>
  -- map q: :q

  -- set noerrorbells
  -- set belloff=all
  -- set vb t_vb=

  -- Make line numbers default
  vim.opt.number = true
  -- You can also add relative line numbers, to help with jumping.
  -- Experiment for yourself to see if you like it!
  -- vim.opt.relativenumber = true

  -- Enable mouse mode, can be useful for resizing splits for example!
  vim.opt.mouse = 'a'

  -- Don't show the mode, since it's already in the status line
  vim.opt.showmode = false

  -- Sync clipboard between OS and Neovim.
  -- Schedule the setting after `UiEnter` because it can increase startup-time.
  -- Remove this option if you want your OS clipboard to remain independent.
  -- See `:help 'clipboard'`
  -- vim.schedule(function()
  --   vim.opt.clipboard = 'unnamedplus'
  -- end)

  -- Enable break indent
  vim.opt.breakindent = true

  -- Save undo history
  vim.opt.undofile = true

  -- Keep signcolumn on by default
  vim.opt.signcolumn = 'yes'

  -- Configure how new splits should be opened
  vim.opt.splitright = true
  vim.opt.splitbelow = true

  -- Preview substitutions live, as you type!
  vim.opt.inccommand = 'split'

  -- Show which line your cursor is on
  vim.opt.cursorline = true

  -- Minimal number of screen lines to keep above and below the cursor.
  vim.opt.scrolloff = 5

  -- Keybinds to make split navigation easier.
  -- Use CTRL+<hjkl> to switch between windows
  -- See `:help wincmd` for a list of all window commands
  vim.keymap.set(
    'n',
    '<C-h>',
    '<C-w><C-h>',
    { desc = 'Move focus to the left window' }
  )
  vim.keymap.set(
    'n',
    '<C-l>',
    '<C-w><C-l>',
    { desc = 'Move focus to the right window' }
  )
  vim.keymap.set(
    'n',
    '<C-j>',
    '<C-w><C-j>',
    { desc = 'Move focus to the lower window' }
  )
  vim.keymap.set(
    'n',
    '<C-k>',
    '<C-w><C-k>',
    { desc = 'Move focus to the upper window' }
  )

  -- Rulers.
  vim.opt.colorcolumn = { 80, 120 }

  -- Remove `~`.
  vim.opt.fillchars = {
    eob = ' ',
  }

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
      vim.opt_local.conceallevel = 0
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
end

local mod = {}

mod.plugins = {
  {
    'kylechui/nvim-surround',
    -- Use for stability; omit to use `main` branch for the latest features
    version = '*',
    event = 'VeryLazy',
    opts = {},
  },

  'michaeljsmith/vim-indent-object',

  {
    'equalsraf/neovim-gui-shim',
    cond = vimrc.determine_ui() == 'nvim-qt',
  },

  -- Detect tabstop and shiftwidth automatically
  {
    'tpope/vim-sleuth',
    event = 'BufRead',
    cond = not vim.g.vscode,
  },

  {
    'farmergreg/vim-lastplace',
    cond = not vim.g.vscode,
  },

  {
    'numToStr/Comment.nvim',
    cond = not vim.g.vscode,
    opts = {},
    config = function(_, opts)
      require('Comment').setup(opts)
      if has_gui_running then
        if vim_os == 'macos' then
          vim.keymap.set(
            'n',
            '<D-/>',
            '<Plug>(comment_toggle_linewise_current)'
          )
          vim.keymap.set(
            'i',
            '<D-/>',
            '<C-o><Plug>(comment_toggle_linewise_current)'
          )
          vim.keymap.set(
            'v',
            '<D-/>',
            '<Plug>(comment_toggle_linewise_visual)gv'
          )
        end
      end
    end,
  },

  -- {
  --   'cohama/lexima.vim',
  --   cond = not vim.g.vscode,
  -- },
  -- Trying this one out because it might work better with cmp.
  {
    'windwp/nvim-autopairs',
    cond = not vim.g.vscode,
    event = 'InsertEnter',
    opts = {},
    config = function(_, opts)
      require('nvim-autopairs').setup(opts)
      -- If you want to automatically add `(` after selecting a function or method
      local cmp_autopairs = require('nvim-autopairs.completion.cmp')
      local cmp = require('cmp')
      cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
    end,
  },

  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    cond = not vim.g.vscode,
    opts = {
      indent = { char = symbols.indent.line },
      scope = { enabled = true, show_exact_scope = true },
    },
  },

  {
    'mhartington/oceanic-next',
    cond = not vim.g.vscode,
    -- Make sure to load this before all the other start plugins.
    priority = 1000,
    dependencies = {
      { 'othree/yajs.vim' },
      { 'othree/html5.vim' },
      { 'HerringtonDarkholme/yats.vim' },
    },
    config = function()
      vim.opt.termguicolors = true
      vim.cmd.syntax('enable')
      vim.cmd.colorscheme('OceanicNext')
    end,
  },
  -- {
  --   'roflolilolmao/oceanic-next.nvim',
  --   cond = not vim.g.vscode,
  --   config = function()
  --     vim.opt.termguicolors = true
  --     vim.cmd.syntax('enable')
  --     vim.cmd.colorscheme('OceanicNext')
  --   end,
  -- },
  -- {
  --   'adrian5/oceanic-next-vim',
  --   cond = not vim.g.vscode,
  --   dependencies = {
  --     { 'othree/yajs.vim' },
  --     { 'othree/html5.vim' },
  --     { 'HerringtonDarkholme/yats.vim' },
  --   },
  --   config = function()
  --     vim.opt.termguicolors = true
  --     vim.cmd.syntax('enable')
  --     vim.cmd.colorscheme('oceanicnext')
  --   end,
  -- },

  {
    'RRethy/vim-illuminate',
    cond = not vim.g.vscode,
    opts = {},
    config = function(_, opts)
      require('illuminate').configure(opts)
    end,
  },
}

return mod
