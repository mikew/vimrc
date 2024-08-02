require('lazy-rtp')

local feature_editor = require('features.editor')
local feature_languages = require('features.languages')
local feature_scm = require('features.scm')
local feature_lsp = require('features.lsp')
local feature_completion = require('features.completion')
local feature_sidebar = require('features.sidebar')
local feature_grep = require('features.grep')

local all_spec = {}
vim.list_extend(all_spec, feature_editor.plugins)
vim.list_extend(all_spec, feature_languages.plugins)
vim.list_extend(all_spec, feature_scm.plugins)
vim.list_extend(all_spec, feature_lsp.plugins)
vim.list_extend(all_spec, feature_completion.plugins)
vim.list_extend(all_spec, feature_sidebar.plugins)
vim.list_extend(all_spec, feature_grep.plugins)

-- Setup lazy.nvim
require('lazy').setup({
  spec = all_spec,
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { 'oceanicnext' } },
  -- automatically check for plugin updates
  -- checker = { enabled = true },
})
