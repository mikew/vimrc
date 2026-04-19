local vimrc = require('vimrc')

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

vim.pack.add({ 'https://github.com/zbirenbaum/copilot.lua' })
vimrc.setup_plugin_lazy(function()
  require('copilot').setup({
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
  })
end)

vim.pack.add({
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/olimorris/codecompanion.nvim',
})
vimrc.setup_plugin_lazy(function()
  require('codecompanion').setup({})
end)
