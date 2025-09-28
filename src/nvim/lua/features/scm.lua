local vimrc = require('vimrc')

local mod = {}

local map = vimrc.keymap

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

          -- Actions
          -- visual mode
          map('stage git hunk', '<leader>hs', 'v', function()
            gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
          end)
          map('reset git hunk', '<leader>hr', 'v', function()
            gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
          end)

          -- normal mode
          map('git [s]tage hunk', '<leader>hs', 'n', gitsigns.stage_hunk)
          map('git [r]eset hunk', '<leader>hr', 'n', gitsigns.reset_hunk)
          map('git [S]tage buffer', '<leader>hS', 'n', gitsigns.stage_buffer)
          map(
            'git [u]ndo stage hunk',
            '<leader>hu',
            'n',
            gitsigns.undo_stage_hunk
          )
          map('git [R]eset buffer', '<leader>hR', 'n', gitsigns.reset_buffer)
          map('git [p]review hunk', '<leader>hp', 'n', gitsigns.preview_hunk)
          map('git [b]lame line', '<leader>hb', 'n', gitsigns.blame_line)
          map('git [d]iff against index', '<leader>hd', 'n', gitsigns.diffthis)
          map('git [D]iff against last commit', '<leader>hD', 'n', function()
            gitsigns.diffthis('@')
          end)

          -- Toggles
          map(
            '[T]oggle git show [b]lame line',
            '<leader>tb',
            'n',
            gitsigns.toggle_current_line_blame
          )
          map(
            '[T]oggle git show [D]eleted',
            '<leader>tD',
            'n',
            gitsigns.preview_hunk_inline
          )
        end,
      },
    },
  }

  return feature
end)

return mod
