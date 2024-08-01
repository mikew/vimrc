local vimrc = require('vimrc')

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
  --
  -- See `:help wincmd` for a list of all window commands
  vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
  vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
  vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
  vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

  -- Rulers.
  vim.opt.colorcolumn = { 80, 120 }

  -- Remove `~`.
  vim.opt.fillchars = {
    eob = ' ',
  }

  -- resize splits if window got resized
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
          vim.keymap.set('n', '<D-/>', '<Plug>(comment_toggle_linewise_current)')
          vim.keymap.set('i', '<D-/>', '<C-o><Plug>(comment_toggle_linewise_current)')
          vim.keymap.set('v', '<D-/>', '<Plug>(comment_toggle_linewise_visual)gv')
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
    opts = {},
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

  -- {
  --   'nvim-neo-tree/neo-tree.nvim',
  --   cond = not vim.g.vscode,
  --   branch = 'v3.x',
  --   dependencies = {
  --     'nvim-lua/plenary.nvim',
  --     'MunifTanjim/nui.nvim',
  --   },
  --   cmd = 'Neotree',
  --   keys = {
  --     { '<leader>e', ':Neotree reveal<CR>', desc = 'NeoTree reveal' },
  --   },
  --   opts = {
  --     window = {
  --       position = 'right',
  --     },
  --   },
  --   init = function()
  --     -- disable netrw
  --     vim.g.loaded_netrw = 1
  --     vim.g.loaded_netrwPlugin = 1
  --   end,
  -- },
  -- Prefer this to neo-tree.
  -- - Persist state across tabs by default.
  {
    'nvim-tree/nvim-tree.lua',
    cond = not vim.g.vscode,
    keys = {
      { '<leader>e', ':NvimTreeFindFile<CR>', desc = 'NvimTreeFindFile' },
    },
    opts = {
      on_attach = function(bufnr)
        local api = require('nvim-tree.api')

        local function opts(desc)
          return {
            desc = 'nvim-tree: ' .. desc,
            buffer = bufnr,
            noremap = true,
            silent = true,
            nowait = true,
          }
        end

        api.config.mappings.default_on_attach(bufnr)

        vim.keymap.set('n', '<CR>', api.node.open.tab, opts('Open: New Tab'))
        vim.keymap.set('n', '<2-LeftMouse>', api.node.open.tab, opts('Open: New Tab'))
        vim.keymap.set('n', '?', api.tree.toggle_help, opts('Help'))
      end,

      disable_netrw = true,

      view = {
        width = 40,
        side = 'right',
        -- TODO Play with this, see what it actually does.
        preserve_window_proportions = true,
      },

      renderer = {
        add_trailing = true,

        indent_markers = {
          enable = true,
        },
      },

      update_focused_file = {
        enable = true,
      },

      diagnostics = {
        enable = true,
        show_on_dirs = true,
      },

      modified = {
        enable = true,
      },

      filters = {
        dotfiles = true,
      },

      tab = {
        sync = {
          open = true,
          close = true,
        },
      },
    },
    init = function()
      -- disable netrw
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
    end,
  },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    cond = not vim.g.vscode,
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',

        -- `build` is used to run some command when the plugin is installed/updated.
        -- This is only run then, not every time Neovim starts up.
        build = 'make',

        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        cond = function()
          return vim.fn.executable('make') == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },

      -- Useful for getting pretty icons, but requires a Nerd Font.
      -- { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function(_, opts)
      -- Telescope is a fuzzy finder that comes with a lot of different things that
      -- it can fuzzy find! It's more than just a "file finder", it can search
      -- many different aspects of Neovim, your workspace, LSP, and more!
      --
      -- The easiest way to use Telescope, is to start by doing something like:
      --  :Telescope help_tags
      --
      -- After running this command, a window will open up and you're able to
      -- type in the prompt window. You'll see a list of `help_tags` options and
      -- a corresponding preview of the help.
      --
      -- Two important keymaps to use while in Telescope are:
      --  - Insert mode: <c-/>
      --  - Normal mode: ?
      --
      -- This opens a window that shows you all of the keymaps for the current
      -- Telescope picker. This is really useful to discover what Telescope can
      -- do as well as how to actually do it!

      -- [[ Configure Telescope ]]
      -- See `:help telescope` and `:help telescope.setup()`
      require('telescope').setup({
        -- You can put your default mappings / updates / etc. in here
        --  All the info you're looking for is in `:help telescope.setup()`
        --
        -- pickers = {}
        defaults = {
          mappings = {
            i = {
              -- ['<c-enter>'] = 'to_fuzzy_refine',
              ['<CR>'] = 'select_tab',
              ['<C-CR>'] = 'select_default',
            },
            n = {
              ['<CR>'] = 'select_tab',
              ['<C-CR>'] = 'select_default',
            },
          },
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      })

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      -- See `:help telescope.builtin`
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })

      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<C-p>', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('i', '<C-p>', builtin.find_files, { desc = '[S]earch [F]iles' })
      if has_gui_running then
        if vim_os == 'macos' then
          vim.keymap.set('n', '<D-t>', builtin.find_files, { desc = '[S]earch [F]iles' })
          vim.keymap.set('i', '<D-t>', builtin.find_files, { desc = '[S]earch [F]iles' })
          vim.keymap.set('n', '<D-p>', builtin.find_files, { desc = '[S]earch [F]iles' })
          vim.keymap.set('i', '<D-p>', builtin.find_files, { desc = '[S]earch [F]iles' })
        end
      end

      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })

      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      if has_gui_running then
        if vim_os == 'macos' then
          vim.keymap.set('n', '<D-F>', builtin.live_grep, { desc = '[S]earch by [G]rep' })
          vim.keymap.set('i', '<D-F>', builtin.live_grep, { desc = '[S]earch by [G]rep' })
        end
      end

      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set(
        'n',
        '<leader>s.',
        builtin.oldfiles,
        { desc = '[S]earch Recent Files ("." for repeat)' }
      )
      vim.keymap.set(
        'n',
        '<leader><leader>',
        builtin.buffers,
        { desc = '[ ] Find existing buffers' }
      )

      -- Slightly advanced example of overriding default behavior and theme
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown({
          winblend = 10,
          previewer = false,
        }))
      end, { desc = '[/] Fuzzily search in current buffer' })

      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep({
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        })
      end, { desc = '[S]earch [/] in Open Files' })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files({ cwd = vim.fn.stdpath('config') })
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },
}

return mod
