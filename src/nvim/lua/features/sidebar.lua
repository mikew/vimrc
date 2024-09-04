local vimrc = require('vimrc')
local symbols = require('symbols')

local mod = {}

mod.plugins = {
  {
    'mikew/nvim-drawer',
    -- dir = vim.fn.expand('~/Work/nvim-drawer'),
    cond = not vim.g.vscode,
    opts = {},
    config = function(_, opts)
      local drawer = require('nvim-drawer')
      drawer.setup(opts)

      drawer.create_drawer({
        size = 40,
        position = 'float',
        nvim_tree_hack = true,

        win_config = {
          margin = 2,
          border = 'rounded',
          anchor = 'CE',
          width = 40,
          height = '80%',
        },

        on_vim_enter = function(event)
          --- Open the drawer on startup.
          -- event.instance.open({
          --   focus = false,
          -- })

          --- Example mapping to toggle.
          vim.keymap.set('n', '<leader>e', function()
            event.instance.focus_or_toggle()
          end)
        end,

        --- Ideally, we would just call this here and be done with it, but
        --- mappings in nvim-tree don't seem to apply when re-using a buffer in
        --- a new tab / window.
        on_did_create_buffer = function()
          local nvim_tree_api = require('nvim-tree.api')
          nvim_tree_api.tree.open({ current_window = true })
        end,

        --- This gets the tree to sync when changing tabs.
        on_did_open = function()
          local nvim_tree_api = require('nvim-tree.api')
          nvim_tree_api.tree.reload()

          vim.opt_local.number = false
          vim.opt_local.signcolumn = 'no'
          vim.opt_local.statuscolumn = ''
        end,

        --- Cleans up some things when closing the drawer.
        on_did_close = function()
          local nvim_tree_api = require('nvim-tree.api')
          nvim_tree_api.tree.close()
        end,
      })

      drawer.create_drawer({
        size = 15,
        position = 'float',

        win_config = {
          anchor = 'SC',
          margin = 2,
          border = 'rounded',
          width = '100%',
          height = 15,
        },

        -- Automatically claim any opened terminals.
        does_own_buffer = function(context)
          return context.bufname:match('term://') ~= nil
        end,

        on_vim_enter = function(event)
          -- Open the drawer on startup.
          event.instance.open({
            focus = false,
          })

          -- Example keymaps:
          -- C-`: focus the drawer.
          -- <leader>tn: open a new terminal.
          -- <leader>tt: go to the next terminal.
          -- <leader>tT: go to the previous terminal.
          -- <leader>tz: zoom the terminal.
          vim.keymap.set('n', '<C-`>', function()
            event.instance.focus_or_toggle()
          end)
          vim.keymap.set('t', '<C-`>', function()
            event.instance.focus_or_toggle()
          end)
          vim.keymap.set('n', '<leader>tn', function()
            event.instance.open({ mode = 'new' })
          end)
          vim.keymap.set('n', '<leader>tt', function()
            event.instance.go(1)
          end)
          vim.keymap.set('n', '<leader>tT', function()
            event.instance.go(-1)
          end)
          vim.keymap.set('n', '<leader>tz', function()
            event.instance.toggle_zoom()
          end)
        end,

        -- When a new buffer is created, switch it to a terminal.
        on_did_create_buffer = function()
          vim.fn.termopen(os.getenv('SHELL'))
        end,

        -- Remove some UI elements.
        on_did_open_buffer = function()
          vim.opt_local.number = false
          vim.opt_local.signcolumn = 'no'
          vim.opt_local.statuscolumn = ''
        end,

        -- Scroll to the end when changing tabs.
        on_did_open = function()
          vim.cmd('$')
        end,
      })

      drawer.create_drawer({
        position = 'float',
        -- Technically unused when using `position = 'float'`.
        size = 40,

        win_config = {
          anchor = 'NC',
          margin = 2,
          border = 'rounded',
          width = '100%',
          height = 10,
        },

        -- Automatically claim any opened NOTES.md file.
        does_own_buffer = function(context)
          return context.bufname:match('NOTES.md') ~= nil
        end,

        on_vim_enter = function(event)
          vim.keymap.set('n', '<leader>nn', function()
            event.instance.focus_or_toggle()
          end)
          vim.keymap.set('n', '<leader>nz', function()
            event.instance.toggle_zoom()
          end)
        end,

        on_did_create_buffer = function()
          vim.cmd('edit NOTES.md')
        end,
      })
    end,
  },
  {
    'nvim-tree/nvim-tree.lua',
    cond = not vim.g.vscode,
    lazy = false,
    opts = {
      on_attach = function(bufnr)
        local api = require('nvim-tree.api')
        local open_file = require('nvim-tree.actions.node.open-file')

        local untouched_modes = {
          'preview',
          'preview_no_picker',
          'vsplit',
          'split',
        }
        local original_fn = open_file.fn
        function open_file.fn(mode, filename)
          if vim.list_contains(untouched_modes, mode) then
            original_fn(mode, filename)
            return
          end

          vimrc.go_to_file_or_open(filename)
        end

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

        vim.keymap.set('n', '<CR>', api.node.open.edit, opts('Open: Tab'))
        vim.keymap.set(
          'n',
          '<2-LeftMouse>',
          api.node.open.edit,
          opts('Open: Tab')
        )
        -- vim.keymap.set('n', '<C-CR>', api.node.open.edit, opts('Open'))
        vim.keymap.set(
          'n',
          '<S-CR>',
          api.node.open.vertical,
          opts('Open: Vertical Split')
        )
        vim.keymap.set('n', '?', api.tree.toggle_help, opts('Help'))

        vim.api.nvim_set_hl(0, 'NvimTreeIndentMarker', {
          link = 'IndentBlankLineChar',
          force = true,
        })
      end,

      hijack_netrw = false,
      -- disable_netrw = true,

      renderer = {
        add_trailing = true,

        indent_markers = {
          enable = true,
          icons = {
            edge = symbols.indent.line,
            item = symbols.indent.line,
          },
        },

        icons = {
          diagnostics_placement = 'before',

          web_devicons = {
            file = {
              enable = false,
              color = true,
            },
            folder = {
              enable = false,
              color = true,
            },
          },

          glyphs = {
            default = '',
            symlink = symbols.generic.symlink,
            bookmark = symbols.generic.star,
            modified = symbols.git.changes,
            hidden = symbols.generic.hidden,
            folder = {
              arrow_closed = '',
              arrow_open = '',
              default = symbols.generic.arrow_right_solid,
              open = symbols.generic.arrow_down_solid,
              empty = symbols.generic.arrow_right,
              empty_open = symbols.generic.arrow_down,
              symlink = symbols.generic.symlink,
              symlink_open = symbols.generic.symlink,
            },
            git = {
              unstaged = symbols.git.changes,
              staged = symbols.git.staged,
              unmerged = symbols.git.untracked,
              renamed = symbols.git.renamed,
              untracked = symbols.git.untracked,
              deleted = symbols.git.deleted,
              ignored = symbols.git.ignored,
            },
          },
        },
      },

      update_focused_file = {
        enable = true,
      },

      diagnostics = {
        enable = true,
        -- show_on_dirs = true,
        icons = {
          hint = symbols.diagnostics.hint,
          info = symbols.diagnostics.info,
          warning = symbols.diagnostics.warn,
          error = symbols.diagnostics.error,
        },
      },

      modified = {
        enable = true,
      },

      filters = {
        dotfiles = true,
      },
    },
    init = function()
      -- disable netrw
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
    end,
  },
}

return mod
