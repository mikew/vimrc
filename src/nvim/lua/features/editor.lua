local vimrc = require('vimrc')
local symbols = require('symbols')
local vimrc_colors = require('vimrc_colors')

local mod = {}
local map = vimrc.keymap

mod.setup = vimrc.make_setup(function(context)
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

  if not vim.g.vscode then
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

    -- TODO
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
    vim.o.number = true
    vim.o.numberwidth = 4
    -- You can also add relative line numbers, to help with jumping.
    -- Experiment for yourself to see if you like it!
    -- vim.o.relativenumber = true

    -- Enable mouse mode, can be useful for resizing splits for example!
    vim.o.mouse = 'a'

    -- Don't show the mode, since it's already in the status line
    vim.o.showmode = false

    -- Sync clipboard between OS and Neovim.
    -- Schedule the setting after `UiEnter` because it can increase startup-time.
    -- Remove this option if you want your OS clipboard to remain independent.
    -- See `:help 'clipboard'`
    -- vim.schedule(function()
    --   vim.o.clipboard = 'unnamedplus'
    -- end)

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

      -- horiz = ' ',
      -- horizup = ' ',
      -- vert = ' ',
      -- vertleft = ' ',
      -- vertright = ' ',
      -- verthoriz = ' ',
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

    -- nvrh integration.
    vim.api.nvim_create_autocmd('UIEnter', {
      group = vimrc.create_augroup('detect_ui'),
      callback = function(event)
        -- `vim.schedule` is needed because some clients need a moment to set
        -- their channel info after connecting.
        vim.schedule(function()
          -- For some reason `event.data` is nil.
          -- local chan = event.data.chan
          -- So instead loop through all the channels, finding the latest where
          -- `client.type` is `ui`.
          --- @type integer?
          local chan
          for _, c in pairs(vim.api.nvim_list_chans()) do
            if c.client and c.client.type == 'ui' then
              chan = c.id
            end
          end

          if not chan then
            return
          end

          local uienter_chan = vim.api.nvim_get_chan_info(chan)

          for _, c in pairs(vim.api.nvim_list_chans()) do
            if
              c.client
              and c.client.name == 'nvrh'
              and c.client.attributes
              and c.client.attributes.nvrh_assumed_ui_channel
                == tostring(chan)
            then
              if uienter_chan.client then
                vimrc.context.ui = uienter_chan.client.name
              end

              local nvrh_client_os = c.client.attributes.nvrh_client_os
              if nvrh_client_os == 'darwin' then
                nvrh_client_os = 'macos'
              end
              vimrc.context.os = nvrh_client_os

              vim.schedule(function()
                require('ginit').setup(true)
              end)
              break
            end
          end
        end)
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
    map(
      'Exit terminal mode',
      '<Esc><Esc>',
      't',
      [[<C-\><C-n>]],
      { noremap = true }
    )

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

        if
          vim.tbl_contains(ignore_ft, ft) or vim.tbl_contains(ignore_bt, bt)
        then
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

        if
          vim.tbl_contains(ignore_ft, ft) or vim.tbl_contains(ignore_bt, bt)
        then
          return
        end

        local cur = vim.api.nvim_win_get_cursor(0)
        if cur[1] > 1 or cur[2] > 0 then
          return
        end

        vim.cmd('silent! loadview')
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
    },

    -- Snacks is entirely too many things, split up across multiple features in
    -- this repo. This initial bit just makes sure we don't enable any feature.
    {
      'folke/snacks.nvim',
      priority = 1000,
      lazy = false,
      ---@type snacks.Config
      opts = {
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
    },

    {
      'RRethy/base16-nvim',
      cond = not vim.g.vscode,
      priority = 1000,
      config = function()
        vim.cmd('colorscheme base16-oceanicnext')

        local function apply_additional_highlights()
          local theme = {}

          theme.background = vimrc_colors.get_hl_color('Normal', 'bg')
            or '#000000'
          theme.background_alt = vimrc_colors.darken(theme.background, 0.3)

          theme.text_primary = vimrc_colors.get_hl_color('Normal', 'fg')
            or '#ffffff'
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
            -- 'snacks_picker_list',
            -- 'snacks_picker_preview',
          },
        }
      end,
      config = function(_, opts)
        require('statuscol').setup(opts)

        vim.api.nvim_create_autocmd('BufWinEnter', {
          callback = function()
            if vim.tbl_contains(opts.ft_ignore, vim.bo.filetype) then
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


    {
      'andymass/vim-matchup',
      cond = not vim.g.vscode,
      main = 'match-up',
      --- @module 'match-up'
      --- @type matchup.Config
      ---@diagnostic disable-next-line: missing-fields
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

            -- Looks like `pwd  branch`
            -- {
            --   function()
            --     return vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
            --   end,
            --   separator = '',
            --   padding = 1,
            -- },
            -- {
            --   'branch',
            --   separator = '',
            --   icon = '',
            --   padding = { left = 0, right = 1 },
            -- },

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

                  if vimrc.has_feature('drawer') then
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
