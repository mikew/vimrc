local vimrc = require('vimrc')
local symbols = require('symbols')

local mod = {}

mod.setup = vimrc.make_setup(function(context)
  -- Set <space> as the leader key
  -- See `:help mapleader`
  --  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be
  --  used)
  --  Space as leader needs to be nooped before it will work.
  vim.keymap.set('n', ' ', '<Nop>', { silent = true, remap = false })
  vim.g.mapleader = ' '
  vim.g.maplocalleader = ' '

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
  vim.opt.foldcolumn = '1'

  -- Indent / outdent.
  vim.keymap.set('v', '<', '<gv')
  vim.keymap.set('v', '>', '>gv')

  -- New line.
  vim.keymap.set('i', '<D-CR>', '<C-o>o')

  if not vim.g.vscode then
    vim.opt.shiftwidth = 2
    vim.opt.tabstop = 2
    vim.opt.softtabstop = 2
    vim.opt.expandtab = true

    vim.opt.termguicolors = true
    vim.opt.cmdheight = 0

    -- Always show tab bar.
    vim.opt.showtabline = 2

    -- Hide inline diagnostics.
    vim.diagnostic.config({
      virtual_text = false,
      float = {
        border = symbols.border.nvim_style,
      },
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
    vim.opt.numberwidth = 4
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
    -- Stop gitsigns and diagnostics from clobbering each other.
    vim.opt.signcolumn = 'yes:2'

    -- Configure how new splits should be opened
    vim.opt.splitright = true
    vim.opt.splitbelow = true

    -- Preview substitutions live, as you type!
    vim.opt.inccommand = 'split'

    -- Show which line your cursor is on
    vim.opt.cursorline = true

    -- Minimal number of screen lines to keep above and below the cursor.
    vim.opt.scrolloff = 5
    vim.opt.mousescroll = 'ver:5,hor:5'

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

      foldopen = symbols.generic.arrow_down,
      foldclose = symbols.generic.arrow_right_solid,
      fold = ' ',
      foldsep = ' ',

      -- horiz = ' ',
      -- horizup = ' ',
      -- vert = ' ',
      -- vertleft = ' ',
      -- vertright = ' ',
      -- verthoriz = ' ',
    }

    -- Only one statusline at the bottom of the window.
    vim.opt.laststatus = 3

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

    -- https://github.com/neovim/neovim/issues/24093
    vim.keymap.set('t', '<S-Enter>', '<Enter>', { desc = 'Insert enter' })
    vim.keymap.set('t', '<S-Space>', '<Space>', { desc = 'Insert space' })
    vim.keymap.set('t', '<S-BS>', '<BS>', { desc = 'Insert backspace' })

    vim.api.nvim_create_autocmd({
      -- Doesn't seem to trigger on startup.
      'WinEnter',
      'BufWinEnter',
    }, {
      group = vimrc.create_augroup('dim_inactive_windows'),
      callback = function()
        vim.o.winhighlight = 'Normal:Normal,NormalNC:BufferLineBackground'
      end,
    })
  end

  --- @type VimrcFeature
  local feature = {
    name = 'editor',
  }

  feature.plugins = {
    {
      'equalsraf/neovim-gui-shim',
      cond = context.ui == 'nvim-qt',
    },

    {
      'kylechui/nvim-surround',
      -- Use for stability; omit to use `main` branch for the latest features
      version = '*',
      event = 'VeryLazy',
      opts = {},
    },

    { 'michaeljsmith/vim-indent-object' },

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
      opts = {
        ignore = '^(%s*)$',
      },
      -- lazy = false,
      keys = function()
        local keys = {}

        if context.has_gui_running then
          if context.os == 'macos' then
            keys = vim.list_extend(keys, {
              {
                '<D-/>',
                '<Plug>(comment_toggle_linewise_current)',
                mode = 'n',
              },
              {
                '<D-/>',
                '<C-o><Plug>(comment_toggle_linewise_current)',
                mode = 'i',
              },
              {
                '<D-/>',
                '<Plug>(comment_toggle_linewise_visual)gv',
                mode = 'v',
              },
            })
          end
        end

        keys = vim.list_extend(keys, {
          {
            '<C-/>',
            '<Plug>(comment_toggle_linewise_current)',
            mode = 'n',
          },
          {
            '<C-/>',
            '<C-o><Plug>(comment_toggle_linewise_current)',
            mode = 'i',
          },
          {
            '<C-/>',
            '<Plug>(comment_toggle_linewise_visual)gv',
            mode = 'v',
          },
        })

        return keys
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

        if vimrc.has_feature('completion') then
          -- If you want to automatically add `(` after selecting a function or method
          local cmp_autopairs = require('nvim-autopairs.completion.cmp')
          local cmp = require('cmp')
          cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
        end
      end,
    },

    -- {
    --   'lukas-reineke/indent-blankline.nvim',
    --   main = 'ibl',
    --   cond = not vim.g.vscode,
    --   event = { 'BufRead' },
    --   opts = {
    --     indent = { char = symbols.indent.line },
    --     scope = { enabled = true, show_exact_scope = true },
    --   },
    -- },
    {
      'nvimdev/indentmini.nvim',
      cond = not vim.g.vscode,
      event = { 'BufRead' },
      opts = {
        char = symbols.indent.line,
      },
      config = function(_, opts)
        vim.api.nvim_set_hl(0, 'IndentLine', {
          link = 'IndentBlankLineChar',
        })
        vim.api.nvim_set_hl(0, 'IndentLineCurrent', {
          link = 'IndentBlankLineContextChar',
        })
        require('indentmini').setup(opts)
      end,
    },

    {
      'RRethy/base16-nvim',
      cond = not vim.g.vscode,
      priority = 1000,
      config = function()
        vim.cmd('colorscheme base16-oceanicnext')

        vim.api.nvim_set_hl(0, 'FloatBorder', {
          link = 'IndentBlankLineChar',
          force = true,
        })
        vim.api.nvim_set_hl(0, 'WinSeparator', {
          link = 'IndentBlankLineChar',
          force = true,
        })
      end,
    },
    -- {
    --   'echasnovski/mini.base16',
    --   cond = not vim.g.vscode,
    --   priority = 1000,
    --   opts = {
    --     -- https://github.com/voronianski/oceanic-next-color-scheme?tab=readme-ov-file#color-palette
    --     palette = {
    --       base00 = '#1B2B34',
    --       base01 = '#343D46',
    --       base02 = '#4F5B66',
    --       base03 = '#65737E',
    --       base04 = '#A7ADBA',
    --       base05 = '#C0C5CE',
    --       base06 = '#CDD3DE',
    --       base07 = '#D8DEE9',
    --       base08 = '#EC5f67',
    --       base09 = '#F99157',
    --       base0A = '#FAC863',
    --       base0B = '#99C794',
    --       base0C = '#5FB3B3',
    --       base0D = '#6699CC',
    --       base0E = '#C594C5',
    --       base0F = '#AB7967',
    --     },
    --   },
    -- },

    {
      'RRethy/vim-illuminate',
      cond = not vim.g.vscode,
      event = { 'InsertEnter' },
      opts = {},
      config = function(_, opts)
        require('illuminate').configure(opts)
      end,
    },

    {
      'luukvbaal/statuscol.nvim',
      cond = not vim.g.vscode,
      opts = function()
        local builtin = require('statuscol.builtin')

        return {
          relculright = true,
          setopt = true,
          segments = {
            -- one space gap
            -- { text = { ' ' } },

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
          ft_ignore = {
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
          },
        }
      end,
      config = function(_, opts)
        require('statuscol').setup(opts)

        vim.api.nvim_create_autocmd({ 'BufEnter' }, {
          callback = function()
            if vim.tbl_contains(opts.ft_ignore, vim.bo.filetype) then
              vim.opt_local.statuscolumn = ''
              vim.opt_local.signcolumn = 'no'
              vim.opt_local.number = false
            end
          end,
        })
      end,
    },

    {
      'nvim-treesitter/nvim-treesitter-context',
      cond = not vim.g.vscode,
      event = { 'BufRead' },
      opts = {
        mode = 'topline',
        multiline_threshold = 2,
      },
    },

    {
      'andymass/vim-matchup',
      cond = not vim.g.vscode,
      opts = {},
    },

    {
      'nvim-lualine/lualine.nvim',
      cond = not vim.g.vscode,
      opts = {
        options = {
          component_separators = { left = '|', right = '|' },
          section_separators = { left = '', right = '' },
        },

        sections = {
          lualine_a = { 'mode' },
          lualine_b = {
            'branch',
            -- {
            --   'diagnostics',
            --   symbols = {
            --     error = symbols.diagnostics.error,
            --     warn = symbols.diagnostics.warn,
            --     info = symbols.diagnostics.info,
            --     hint = symbols.diagnostics.hint,
            --   },
            -- },
          },
          lualine_c = { 'filename' },

          lualine_x = { 'filetype' },
          lualine_y = {},
          lualine_z = { 'location' },
        },
      },
    },

    {
      'akinsho/bufferline.nvim',
      cond = not vim.g.vscode,
      opts = {
        options = {
          mode = 'tabs',

          -- numbers = function(opts)
          --   return string.format('%s', opts.ordinal)
          -- end,

          -- close_command = 'tabclose',
          -- close_command = function(n)
          --   return string.format('tabdo bdelete %d', n.id)
          -- end,

          left_trunc_marker = '◀',
          right_trunc_marker = '▶',

          right_mouse_command = false,

          show_buffer_icons = false,
          -- show_close_icon = false,
          -- show_buffer_close_icons = false,

          diagnostics = 'nvim_lsp',

          --- @param buf { name: string, path: string, bufnr: integer, buffers: integer[], tabnr: integer }
          name_formatter = function(buf)
            local to_check = {
              -- Start with the focused window.
              vim.api.nvim_tabpage_get_win(buf.tabnr),
            }
            -- Then add all other windows in the tab.
            vim.list_extend(to_check, vim.api.nvim_tabpage_list_wins(buf.tabnr))

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

              if vim.list_contains(context.features, 'drawer') then
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
                bufname = '[No Name]'
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

            return '[No Name]'
          end,
        },
      },
    },

    {
      'kevinhwang91/nvim-ufo',
      cond = not vim.g.vscode,
      dependencies = {
        'kevinhwang91/promise-async',
      },
      opts = {
        provider_selector = function(bufnr, filetype, buftype)
          return { 'treesitter', 'indent' }
        end,
      },
    },
  }

  return feature
end)

return mod
