require('config.lazy-rtp')

local feature_editor = require('features.editor')
local feature_languages = require('features.languages')
local feature_scm = require('features.scm')
local feature_lsp = require('features.lsp')

local all_spec = {}
vim.list_extend(all_spec, feature_editor.plugins)
vim.list_extend(all_spec, feature_languages.plugins)
vim.list_extend(all_spec, feature_scm.plugins)
vim.list_extend(all_spec, feature_lsp.plugins)

-- Setup lazy.nvim
require('lazy').setup({
  spec = all_spec,
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { 'oceanicnext' } },
  -- automatically check for plugin updates
  -- checker = { enabled = true },
})
