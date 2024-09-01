local mod = {}

mod.plugins = {
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

return mod
