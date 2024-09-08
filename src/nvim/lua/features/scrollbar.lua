local vimrc = require('vimrc')
local symbols = require('symbols')

local mod = {}

mod.setup = vimrc.make_setup(function(context)
  --- @type VimrcFeature
  local feature = {
    name = 'scrollbar',
  }

  feature.plugins = {
    -- First impressions are I like it. Acts like a scrollbar, a little noisy
    -- tho.
    -- I like the mouse behavior where clicking an area scrolls directly to that
    -- area, rather than scrolling up/down a page.
    -- Not a huge fan of the symbols moving.
    {
      'dstein64/nvim-scrollview',
      cond = not vim.g.vscode,
      opts = {
        excluded_filetypes = {
          'NvimTree',
        },

        -- current_only = true,
        signs_on_startup = {
          'conflicts',
          'cursor',
          'diagnostics',
          'search',
        },

        diagnostics_hint_symbol = symbols.diagnostics.hint,
        diagnostics_info_symbol = symbols.diagnostics.info,
        diagnostics_warn_symbol = symbols.diagnostics.warn,
        diagnostics_error_symbol = symbols.diagnostics.error,
      },

      config = function(_, opts)
        require('scrollview').setup(opts)
        if vimrc.has_feature('scm') then
          require('scrollview.contrib.gitsigns').setup()
        end
      end,
    },
    -- Ding ding ding ding, we might have a winner.
    -- Very comparable to nvim-scrollbar, but I like how with satellite, the SCM
    -- markers are outside of the scrollbar.
    -- {
    --   'lewis6991/satellite.nvim',
    --   opts = {
    --     winblend = 0,
    --   },
    -- },
  }

  return feature
end)

return mod
