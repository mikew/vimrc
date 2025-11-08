local vimrc = require('vimrc')

local mod = {}

local map = vimrc.keymap

mod.setup = vimrc.make_setup(function(context)
  --- @type VimrcFeature
  local feature = {
    name = 'grep',
  }

  feature.plugins = {
    {
      'folke/snacks.nvim',
      ---@type snacks.Config
      opts = {
        picker = {
          enabled = true,
          ui_select = false,

          on_show = function(picker)
            -- Fix when launching a picker from terminal.
            -- https://github.com/folke/snacks.nvim/discussions/2164#discussioncomment-14278259
            vim.schedule(function()
              vim.cmd('startinsert')
            end)
          end,

          matcher = {
            sort_empty = true,
            frecency = true,
            history_bonus = true,
          },

          sources = {
            git_grep = {
              ignorecase = true,
            },
          },

          jump = {
            reuse_win = true, -- reuse an existing window if the buffer is already open
            match = true, -- jump to the first match position. (useful for `lines`)
          },

          win = {
            input = {
              keys = {
                ['<CR>'] = { 'tabdrop', mode = { 'n', 'i' } },
                ['<C-CR>'] = { 'split', mode = { 'n', 'i' } },
                ['<S-CR>'] = { 'vsplit', mode = { 'n', 'i' } },
              },
            },

            list = {
              wo = {
                statuscolumn = '',
                signcolumn = 'no',
                number = false,
                foldcolumn = '0',
              },

              keys = {
                ['<CR>'] = 'tabdrop',
                ['<C-CR>'] = 'split',
                ['<S-CR>'] = 'vsplit',
              },
            },

            preview = {
              wo = {
                statuscolumn = '',
                signcolumn = 'no',
                number = false,
                foldcolumn = '0',
              },
            },
          },
        },
      },
      config = function(_, opts)
        require('picker_patches')
        local snacks = require('snacks')
        snacks.setup(opts)

        map('Find Files', '<C-p>', { 'n', 'i', 't' }, function()
          snacks.picker.git_files({ untracked = true })
        end)
        if context.has_gui_running then
          if context.os == 'macos' then
            map('Find Files', '<D-t>', { 'n', 'i', 't' }, function()
              snacks.picker.git_files({ untracked = true })
            end)
            map('Find Files', '<D-p>', { 'n', 'i', 't' }, function()
              snacks.picker.git_files({ untracked = true })
            end)
          end
        end

        map('Search by Grep', '<C-S-F>', { 'n', 'i', 't' }, function()
          snacks.picker.git_grep({ untracked = true })
        end)
        if context.has_gui_running then
          if context.os == 'macos' then
            map('Search by Grep', '<D-F>', { 'n', 'i', 't' }, function()
              snacks.picker.git_grep({ untracked = true })
            end)
          end
        end

        map('Search Diagnostics', '<leader>sd', 'n', function()
          snacks.picker.diagnostics()
        end)

        map('Resume Search', '<leader>sr', 'n', function()
          snacks.picker.resume()
        end)

        map('Find Buffers', '<leader><leader>', 'n', function()
          snacks.picker.buffers()
        end)
      end,
    },
  }

  return feature
end)

return mod
