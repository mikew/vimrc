local vimrc = require('vimrc')

local mod = {}

mod.setup = vimrc.make_setup(function(context)
  --- @type VimrcFeature
  local feature = {
    name = 'ai',
  }

  feature.plugins = {
    {
      'github/copilot.vim',
      cond = not vim.g.vscode,
      init = function()
        vim.g.copilot_no_tab_map = true
        vim.keymap.set('i', '<C-CR>', 'copilot#Accept("")', {
          expr = true,
          replace_keycodes = false,
        })
      end,
      config = function() end,
    },
  }

  return feature
end)

return mod
