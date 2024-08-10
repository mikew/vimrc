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

local feature_ai = require('features.ai')
vimrc.register_feature('ai')

local all_spec = {}
vim.list_extend(all_spec, feature_editor.plugins)
vim.list_extend(all_spec, feature_languages.plugins)
vim.list_extend(all_spec, feature_scm.plugins)
vim.list_extend(all_spec, feature_lsp.plugins)
vim.list_extend(all_spec, feature_completion.plugins)
vim.list_extend(all_spec, feature_sidebar.plugins)
vim.list_extend(all_spec, feature_grep.plugins)
vim.list_extend(all_spec, feature_scrollbar.plugins)
vim.list_extend(all_spec, feature_ai.plugins)

-- local drawer_port = require('drawer_port')
-- local wut_legacy = drawer_port.create({
--   buf_name_prefix = 'test_',
--   position = 'bottom',
--   size = 10,
--   on_will_create_buffer = function(bufname)
--     print('on_will_create_buffer', bufname)
--
--     -- vim.fn.termopen(os.getenv('SHELL'))
--     -- require('nvim-tree.api').tree.open({ current_window = true })
--   end,
--   on_did_open_split = function()
--     --   print('on_did_open_split')
--     require('nvim-tree.api').tree.open({ current_window = true })
--   end,
--   -- on_did_open_drawer = function(bufname)
--   --   print('on_did_open_drawer', bufname)
--   -- end,
-- })
-- vim.g.wut_legacy = wut_legacy

local drawer = require('drawer')
local tree_drawer = drawer.create_drawer({
  bufname_prefix = 'test_',
  size = 10,

  on_will_create_buffer = function(bufname)
    require('nvim-tree.api').tree.open({ current_window = true })
    vim.cmd('file ' .. bufname)
  end,
})
vim.g.wut = tree_drawer

local terminal_drawer = drawer.create_drawer({
  bufname_prefix = 'quick_terminal_',
  size = 15,

  on_will_create_buffer = function(bufname)
    vim.print('on_will_create_buffer', bufname)
    vim.fn.termopen(os.getenv('SHELL'))
  end,
})
vim.g.wut2 = terminal_drawer

-- Setup lazy.nvim
require('lazy').setup({
  spec = all_spec,
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { 'oceanicnext' } },
  -- automatically check for plugin updates
  -- checker = { enabled = true },
})
