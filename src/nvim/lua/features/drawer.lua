local vimrc = require('vimrc')
local symbols = require('symbols')
local map = vimrc.keymap

local mod = {}

mod.setup = vimrc.make_setup(function()
  --- @type VimrcFeature
  local feature = {
    name = 'drawer',
  }

  feature.plugins = {
    {
      'mikew/nvim-drawer',
      -- dir = vim.fn.expand('~/Work/nvim-drawer'),
      cond = not vim.g.vscode,
      opts = {
        position_order = { 'left', 'right', 'above', 'below', 'float' },
      },
      config = function(_, opts)
        local drawer = require('nvim-drawer')
        drawer.setup(opts)

        drawer.create_drawer({
          size = 40,
          position = 'right',
          should_reuse_previous_bufnr = false,
          should_close_on_bufwipeout = false,

          win_config = {
            margin = 2,
            border = symbols.border.nvim_style,
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
            map('Toggle file explorer', '<leader>e', 'n', function()
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
          position = 'below',

          win_config = {
            anchor = 'SC',
            margin = 2,
            border = symbols.border.nvim_style,
            width = '100%',
            height = 15,
          },

          -- Automatically claim any opened terminals.
          does_own_buffer = function(context)
            return context.bufname:match('term://') ~= nil
          end,

          on_vim_enter = function(event)
            -- Open the drawer on startup.
            -- event.instance.open({
            --   focus = false,
            -- })

            -- Example keymaps:
            -- C-`: focus the drawer.
            -- <leader>tn: open a new terminal.
            -- <leader>tt: go to the next terminal.
            -- <leader>tT: go to the previous terminal.
            -- <leader>tz: zoom the terminal.
            map('Focus or toggle terminal', '<C-`>', { 'n', 't' }, function()
              event.instance.focus_or_toggle()
            end)
            map('Open new terminal', '<leader>tn', 'n', function()
              event.instance.open({ mode = 'new' })
            end)
            map('Go to next terminal', '<leader>tt', 'n', function()
              event.instance.go(1)
            end)
            map('Go to previous terminal', '<leader>tT', 'n', function()
              event.instance.go(-1)
            end)
            map('Toggle terminal zoom', '<leader>tz', 'n', function()
              event.instance.toggle_zoom()
            end)
          end,

          -- When a new buffer is created, switch it to a terminal.
          on_did_create_buffer = function(event)
            vim.api.nvim_buf_call(event.bufnr, function()
              -- Intentionally not using `vim.o.shell` directly. When started
              -- from powershell it defaults to `cmd.exe`.
              -- local shell = vim.o.shell
              local shell = ''

              local shell_env = vim.env.SHELL
              if shell_env and shell_env ~= '' then
                shell = shell_env
              elseif vim.env.PSMODULEPATH then
                shell = vim.env.SYSTEMROOT
                  .. [[\System32\WindowsPowerShell\v1.0\powershell.exe]]
              elseif vim.env.COMSPEC and vim.env.PROMPT then
                shell = 'cmd.exe'
              end

              if not shell or shell == '' then
                vim.notify(
                  'Could not determine shell to open terminal drawer',
                  vim.log.levels.ERROR
                )
                return
              end

              vim.fn.jobstart(shell, { term = true })
            end)
          end,

          -- Remove some UI elements.
          on_did_open_buffer = function()
            vim.opt_local.number = false
            vim.opt_local.signcolumn = 'no'
            vim.opt_local.statuscolumn = ''
            vim.opt_local.foldcolumn = '0'
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
            border = symbols.border.nvim_style,
            width = '100%',
            height = 10,
          },

          -- Automatically claim any opened NOTES.md file.
          does_own_buffer = function(context)
            return context.bufname:match('NOTES.md') ~= nil
          end,

          on_vim_enter = function(event)
            map('Toggle notes', '<leader>nn', 'n', function()
              event.instance.focus_or_toggle()
            end)
            map('Toggle notes zoom', '<leader>nz', 'n', function()
              event.instance.toggle_zoom()
            end)
          end,

          on_did_create_buffer = function()
            vim.cmd('edit NOTES.md')
          end,
        })

        drawer.create_drawer({
          position = 'below',
          size = 30,

          does_own_window = function(context)
            return context.bufname:match('spectre') ~= nil
          end,

          on_vim_enter = function(event)
            map('Toggle search and replace', '<leader>S', 'n', function()
              -- If the drawer has never been opened, call spectre. Once its
              -- window opens, it will be claimed by the drawer, and we can use
              -- the drawer API afterwards.
              if
                #vim.tbl_keys(event.instance.state.windows_and_buffers) == 0
              then
                require('spectre').toggle()
              else
                event.instance.focus_or_toggle()
              end
            end)
          end,

          -- Remove some UI elements.
          on_did_open_buffer = function()
            vim.opt_local.number = false
            vim.opt_local.signcolumn = 'no'
            vim.opt_local.statuscolumn = ''
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

          api.config.mappings.default_on_attach(bufnr)

          map(
            'nvim-tree: Open: Tab',
            '<CR>',
            'n',
            api.node.open.edit,
            { buffer = bufnr, noremap = true, silent = true, nowait = true }
          )
          map(
            'nvim-tree: Open: Tab',
            '<2-LeftMouse>',
            'n',
            api.node.open.edit,
            { buffer = bufnr, noremap = true, silent = true, nowait = true }
          )
          -- vim.keymap.set('n', '<C-CR>', api.node.open.edit, opts('Open'))
          map(
            'nvim-tree: Open: Vertical Split',
            '<S-CR>',
            'n',
            api.node.open.vertical,
            { buffer = bufnr, noremap = true, silent = true, nowait = true }
          )
          map(
            'nvim-tree: Help',
            '?',
            'n',
            api.tree.toggle_help,
            { buffer = bufnr, noremap = true, silent = true, nowait = true }
          )
        end,

        hijack_netrw = false,
        -- disable_netrw = true,

        renderer = {
          add_trailing = true,

          indent_markers = {
            enable = true,
            icons = {
              edge = symbols.indent.line,
              item = symbols.border.symbols.left_joiner,
              corner = symbols.border.symbols.bottom_left,
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

        actions = {
          open_file = {
            window_picker = {
              enable = false,
            },
          },
        },
      },

      init = function()
        -- disable netrw
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1
      end,

      config = function(_, opts)
        local nvim_tree = require('nvim-tree')
        nvim_tree.setup(opts)
      end,
    },

    {
      'nvim-pack/nvim-spectre',
      cond = not vim.g.vscode,
      opts = {
        mapping = {
          ['enter_file'] = {
            map = '<cr>',
            cmd = "<cmd>lua require('features.drawer').spectre_select_entry()<CR>",
            desc = 'open file',
          },
        },
      },
    },
  }

  return feature
end)

function mod.spectre_select_entry()
  local spectre_actions = require('spectre.actions')

  local spectre_entry = spectre_actions.get_current_entry()

  if spectre_entry == nil then
    return
  end

  vimrc.go_to_file_or_open(
    spectre_entry.filename,
    { spectre_entry.lnum, spectre_entry.col - 1 }
  )
end

return mod
