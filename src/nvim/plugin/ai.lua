local vimrc = require('vimrc')
local vimrc_pack = require('vimrc_pack')

if vimrc.is_feature_disabled('ai') then
  return
end

-- {
--   'github/copilot.vim',
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

vimrc_pack.add({
  {
    'https://github.com/zbirenbaum/copilot.lua',
    lazy = 'VimEnter',
    setup = function()
      -- TODO This should be done in an on_ui_enter callback.
      local accept_key = '<C-CR>'
      if os.getenv('TMUX') ~= nil then
        accept_key = '<C-M>'
      end

      require('copilot').setup({
        panel = {
          enabled = false,
        },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          keymap = {
            accept = accept_key,
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
      })
    end,
  },
})

vimrc_pack.add({
  {
    'https://github.com/sudo-tee/opencode.nvim',
    lazy = 'VimEnter',
    setup = function()
      require('opencode').setup({
        default_mode = 'plan',

        server = {
          url = '10.0.1.99',
          port = 4096,
          password = function()
            local keyfile = vim.fn.expand('~/.secrets/opencode-serve-key')
            if vim.fn.filereadable(keyfile) == 1 then
              return vim.fn.trim(vim.fn.readfile(keyfile)[1])
            end
          end,
        },
      })
    end,
  },
})
