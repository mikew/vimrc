local vimrc = require('vimrc')
local symbols = require('symbols')

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
      },
    },

    {
      'yetone/avante.nvim',
      event = 'VeryLazy',
      lazy = false,

      -- set this to "*" if you want to always pull the latest change, false to update on release
      version = false,

      -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
      build = 'make',
      -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows

      dependencies = {
        'stevearc/dressing.nvim',
        'nvim-lua/plenary.nvim',
        'MunifTanjim/nui.nvim',
        --- The below dependencies are optional,
        -- 'hrsh7th/nvim-cmp', -- autocompletion for avante commands and mentions
        -- 'nvim-tree/nvim-web-devicons', -- or echasnovski/mini.icons
        -- 'zbirenbaum/copilot.lua', -- for providers='copilot'
        -- {
        --   -- support for image pasting
        --   'HakonHarnes/img-clip.nvim',
        --   event = 'VeryLazy',
        --   opts = {
        --     -- recommended settings
        --     default = {
        --       embed_image_as_base64 = false,
        --       prompt_for_file_name = false,
        --       drag_and_drop = {
        --         insert_mode = true,
        --       },
        --       -- required for Windows users
        --       use_absolute_path = true,
        --     },
        --   },
        -- },
        {
          -- Make sure to set this up properly if you have lazy=true
          'MeanderingProgrammer/render-markdown.nvim',
          opts = {
            file_types = { 'markdown', 'Avante' },
          },
          ft = { 'markdown', 'Avante' },
        },
      },
      opts = {
        provider = 'claude',
        auto_suggestions_provider = 'claude',
        -- behaviour = {
        --   auto_suggestions = false, -- Experimental stage
        --   auto_set_highlight_group = true,
        --   auto_set_keymaps = true,
        --   auto_apply_diff_after_generation = false,
        --   support_paste_from_clipboard = false,
        --   minimize_diff = true, -- Whether to remove unchanged lines when applying a code block
        -- },
        -- mappings = {
        --   --- @class AvanteConflictMappings
        --   diff = {
        --     ours = 'co',
        --     theirs = 'ct',
        --     all_theirs = 'ca',
        --     both = 'cb',
        --     cursor = 'cc',
        --     next = ']x',
        --     prev = '[x',
        --   },
        --   suggestion = {
        --     accept = '<M-l>',
        --     next = '<M-]>',
        --     prev = '<M-[>',
        --     dismiss = '<C-]>',
        --   },
        --   jump = {
        --     next = ']]',
        --     prev = '[[',
        --   },
        --   submit = {
        --     normal = '<CR>',
        --     insert = '<C-s>',
        --   },
        --   sidebar = {
        --     apply_all = 'A',
        --     apply_cursor = 'a',
        --     switch_windows = '<Tab>',
        --     reverse_switch_windows = '<S-Tab>',
        --   },
        -- },
        windows = {
          position = 'right',
          width = 30,
          sidebar_header = {
            enabled = false,
          },
          input = {
            prefix = '> ',
            height = 8,
          },
          edit = {
            border = symbols.border.nvim_style,
            start_insert = true,
          },
          ask = {
            border = symbols.border.nvim_style,
          },
        },
      },
    },
  }

  return feature
end)

return mod
