local vimrc = require('vimrc')

local mod = {}

mod.setup = vimrc.make_setup(function(context)
  --- @type VimrcFeature
  local feature = {
    name = 'scm',
  }

  feature.plugins = {
    {
      'lewis6991/gitsigns.nvim',
      cond = not vim.g.vscode,
      opts = {
        on_attach = function(bufnr)
          local gitsigns = require('gitsigns')

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Actions
          -- visual mode
          map('v', '<leader>hs', function()
            gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
          end, { desc = 'stage git hunk' })
          map('v', '<leader>hr', function()
            gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
          end, { desc = 'reset git hunk' })

          -- normal mode
          map(
            'n',
            '<leader>hs',
            gitsigns.stage_hunk,
            { desc = 'git [s]tage hunk' }
          )
          map(
            'n',
            '<leader>hr',
            gitsigns.reset_hunk,
            { desc = 'git [r]eset hunk' }
          )
          map(
            'n',
            '<leader>hS',
            gitsigns.stage_buffer,
            { desc = 'git [S]tage buffer' }
          )
          map(
            'n',
            '<leader>hu',
            gitsigns.stage_hunk,
            { desc = 'git [u]ndo stage hunk' }
          )
          map(
            'n',
            '<leader>hR',
            gitsigns.reset_buffer,
            { desc = 'git [R]eset buffer' }
          )
          map(
            'n',
            '<leader>hp',
            gitsigns.preview_hunk,
            { desc = 'git [p]review hunk' }
          )
          map(
            'n',
            '<leader>hb',
            gitsigns.blame_line,
            { desc = 'git [b]lame line' }
          )
          map(
            'n',
            '<leader>hd',
            gitsigns.diffthis,
            { desc = 'git [d]iff against index' }
          )
          map('n', '<leader>hD', function()
            gitsigns.diffthis('@')
          end, { desc = 'git [D]iff against last commit' })

          -- Toggles
          map(
            'n',
            '<leader>tb',
            gitsigns.toggle_current_line_blame,
            { desc = '[T]oggle git show [b]lame line' }
          )
          map(
            'n',
            '<leader>tD',
            gitsigns.preview_hunk_inline,
            { desc = '[T]oggle git show [D]eleted' }
          )
        end,
      },
    },
  }

  return feature
end)

return mod
