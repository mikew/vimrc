require('lazy-rtp')

local vimrc = require('vimrc')
local feature_editor = require('features.editor')
vimrc.register_feature('editor')
local feature_languages = require('features.languages')
vimrc.register_feature('languages')
local feature_scm = require('features.scm')
vimrc.register_feature('scm')
local feature_lsp = require('features.lsp')
vimrc.register_feature('lsp')
local feature_completion = require('features.completion')
vimrc.register_feature('completion')
local feature_sidebar = require('features.sidebar')
vimrc.register_feature('sidebar')
local feature_grep = require('features.grep')
vimrc.register_feature('grep')
local feature_scrollbar = require('features.scrollbar')
vimrc.register_feature('scrollbar')

local all_spec = {}
vim.list_extend(all_spec, feature_editor.plugins)
vim.list_extend(all_spec, feature_languages.plugins)
vim.list_extend(all_spec, feature_scm.plugins)
vim.list_extend(all_spec, feature_lsp.plugins)
vim.list_extend(all_spec, feature_completion.plugins)
vim.list_extend(all_spec, feature_sidebar.plugins)
vim.list_extend(all_spec, feature_grep.plugins)
vim.list_extend(all_spec, feature_scrollbar.plugins)

-- Setup lazy.nvim
require('lazy').setup({
  spec = all_spec,
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { 'oceanicnext' } },
  -- automatically check for plugin updates
  -- checker = { enabled = true },
})
