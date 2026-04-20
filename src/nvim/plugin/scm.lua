local vimrc = require('vimrc')
local vimrc_pack = require('vimrc_pack')
local symbols = require('symbols')

local map = vimrc.keymap

vimrc_pack.add({
  {
    'https://github.com/lewis6991/gitsigns.nvim',
    lazy = 'VimEnter',
    setup = function()
      require('gitsigns').setup({
        preview_config = {
          border = symbols.border.nvim_style,
        },
        on_attach = function(bufnr)
          local gitsigns = require('gitsigns')

          -- Actions
          -- visual mode
          map('stage git hunk', '<leader>hs', 'v', function()
            gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
          end, { buffer = bufnr })
          map('reset git hunk', '<leader>hr', 'v', function()
            gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
          end, { buffer = bufnr })

          -- normal mode
          map(
            'git [s]tage hunk',
            '<leader>hs',
            'n',
            gitsigns.stage_hunk,
            { buffer = bufnr }
          )
          map(
            'git [r]eset hunk',
            '<leader>hr',
            'n',
            gitsigns.reset_hunk,
            { buffer = bufnr }
          )
          map(
            'git [S]tage buffer',
            '<leader>hS',
            'n',
            gitsigns.stage_buffer,
            { buffer = bufnr }
          )
          map(
            'git [u]ndo stage hunk',
            '<leader>hu',
            'n',
            gitsigns.stage_hunk,
            { buffer = bufnr }
          )
          map(
            'git [R]eset buffer',
            '<leader>hR',
            'n',
            gitsigns.reset_buffer,
            { buffer = bufnr }
          )
          map(
            'git [p]review hunk',
            '<leader>hp',
            'n',
            gitsigns.preview_hunk,
            { buffer = bufnr }
          )
          map(
            'git [b]lame line',
            '<leader>hb',
            'n',
            gitsigns.blame_line,
            { buffer = bufnr }
          )
          map(
            'git [d]iff against index',
            '<leader>hd',
            'n',
            gitsigns.diffthis,
            { buffer = bufnr }
          )
          map('git [D]iff against last commit', '<leader>hD', 'n', function()
            gitsigns.diffthis('@')
          end, { buffer = bufnr })

          -- Toggles
          map(
            '[T]oggle git show [b]lame line',
            '<leader>tb',
            'n',
            gitsigns.toggle_current_line_blame,
            { buffer = bufnr }
          )
          map(
            '[T]oggle git show [D]eleted',
            '<leader>tD',
            'n',
            gitsigns.preview_hunk_inline,
            { buffer = bufnr }
          )
        end,
      })
    end,
  },
})
