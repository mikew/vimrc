local symbols = require('symbols')
local drawer = require('drawer')

local mod = {}

local tree_drawer = drawer.create_drawer({
  bufname_prefix = 'tree_',
  size = 40,
  position = 'right',

  on_did_open_buffer = function()
    local nvim_tree_api = require('nvim-tree.api')
    nvim_tree_api.tree.open({ current_window = true })
    nvim_tree_api.tree.reload()

    -- NvimTree seems to set this back to true.
    vim.opt_local.winfixheight = false

    vim.opt_local.number = false
    vim.opt_local.signcolumn = 'no'
    vim.opt_local.statuscolumn = ''
  end,

  on_did_close = function()
    local nvim_tree_api = require('nvim-tree.api')
    nvim_tree_api.tree.close()
  end,
})

-- This is the trick to getting NvimTree working in a drawer.
-- We let NvimTree completely overwrite the split, which ends up renaming it to
-- something like `NvimTree_{N}`.
-- Then, we overwrite how the drawer is found so that any NvimTree windows are
-- found instead of drawer windows.
local original_is_buffer = tree_drawer.is_buffer
function tree_drawer.is_buffer(bufname)
  return string.find(bufname, 'NvimTree_') ~= nil or original_is_buffer(bufname)
end

vim.keymap.set('n', '<leader>e', function()
  tree_drawer.focus_or_toggle()
end, {
  desc = 'Toggle Tree Drawer',
  noremap = true,
  silent = true,
})

local terminal_drawer = drawer.create_drawer({
  bufname_prefix = 'quick_terminal_',
  size = 15,
  position = 'bottom',

  on_will_create_buffer = function()
    vim.fn.termopen(os.getenv('SHELL'))

    vim.opt_local.number = false
    vim.opt_local.signcolumn = 'no'
    vim.opt_local.statuscolumn = ''
  end,
})

vim.keymap.set('n', '<C-`>', function()
  terminal_drawer.focus_or_toggle()
end)

vim.keymap.set('n', '<leader>tn', function()
  terminal_drawer.open({ mode = 'new' })
end)

vim.keymap.set('n', '<leader>tt', function()
  terminal_drawer.go(1)
end)

vim.keymap.set('n', '<leader>tT', function()
  terminal_drawer.go(-1)
end)

vim.api.nvim_create_autocmd('VimEnter', {
  desc = 'Open Tree automatically',
  once = true,
  callback = function()
    tree_drawer.open()
    terminal_drawer.open()
  end,
})

mod.plugins = {
  {
    'nvim-tree/nvim-tree.lua',
    cond = not vim.g.vscode,
    lazy = false,
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
        vim.keymap.set(
          'n',
          '<2-LeftMouse>',
          api.node.open.tab,
          opts('Open: New Tab')
        )
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
