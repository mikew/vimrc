local symbols = require('symbols')
local drawer = require('drawer')

local mod = {}

local tree_drawer = drawer.create_drawer({
  bufname_prefix = 'test_',
  size = 40,
  position = 'right',

  -- on_will_create_buffer = function(bufname)
  --   require('nvim-tree.api').tree.open({ current_window = true })
  --   vim.cmd('file ' .. bufname)
  -- end,

  on_did_open_buffer = function(bufname)
    vim.print('on_did_open_buffer', bufname)
    vim.cmd('buffer NvimTree_1')
    -- require('nvim-tree.api').tree.open({ current_window = true })
    -- require('neo-tree.command').execute({
    --   position = 'current',
    -- })
  end,
})

vim.keymap.set('n', '<leader>e', function()
  tree_drawer.Toggle()
end, {
  desc = 'Toggle Tree Drawer',
  noremap = true,
  silent = true,
})

-- vim.api.nvim_create_autocmd('VimEnter', {
--   desc = 'Open Tree automatically',
--   once = true,
--   callback = function()
--     tree_drawer.Open()
--   end,
-- })
--
mod.plugins = {
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
    lazy = false,
    -- keys = {
    --   { '<leader>e', '<Cmd>NvimTreeFindFile<CR>', desc = 'NvimTreeFindFile' },
    -- },
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

      -- tab = {
      --   sync = {
      --     open = true,
      --     close = true,
      --   },
      -- },
    },
    init = function()
      -- disable netrw
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      -- vim.api.nvim_create_autocmd('VimEnter', {
      --   desc = 'Open Tree automatically',
      --   once = true,
      --   command = 'NvimTreeFindFile | wincmd p',
      -- })
    end,
  },

  {
    'nvim-neo-tree/neo-tree.nvim',
    opts = {},
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- 'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
      'MunifTanjim/nui.nvim',
      -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
    },
  },
}

return mod
