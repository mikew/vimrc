local vimrc = require('vimrc')

local mod = {}

mod.setup = vimrc.make_setup(function(context)
  --- @type VimrcFeature
  local feature = {
    name = 'ai',
  }

  feature.plugins = {
    -- {
    --   'github/copilot.vim',
    --   cond = not vim.g.vscode,
    --   init = function()
    --     vim.g.copilot_no_tab_map = true
    --     vim.g.copilot_node_command =
    --       '~/.local/share/mise/installs/node/latest/bin/node'
    --     vim.keymap.set('i', '<C-CR>', 'copilot#Accept("")', {
    --       expr = true,
    --       replace_keycodes = false,
    --     })
    --   end,
    --   config = function() end,
    -- },

    {
      'zbirenbaum/copilot.lua',
      cond = not vim.g.vscode,
      event = 'InsertEnter',
      opts = {
        panel = {
          enabled = false,
        },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          keymap = {
            accept = '<C-CR>',
            -- accept_word = false,
            -- accept_line = false,
            -- next = '<M-]>',
            -- prev = '<M-[>',
            -- dismiss = '<C-]>',
          },
        },
        filetypes = {
          yaml = true,
          markdown = true,
          gitcommit = true,
          gitrebase = false,
        },
        copilot_node_command = {
          'mise-global-tool',
          'node',
        },
      },
    },

    {
      'olimorris/codecompanion.nvim',
      opts = {},
      dependencies = {
        'nvim-lua/plenary.nvim',
      },
    },
  }

  return feature
end)

return mod
