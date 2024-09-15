local vimrc = require('vimrc')
local symbols = require('symbols')

require('features.editor').setup(vimrc.context)

require('features.languages').setup(vimrc.context)

require('features.scm').setup(vimrc.context)

require('features.lsp').setup(vimrc.context)

require('features.completion').setup(vimrc.context)

require('features.drawer').setup(vimrc.context)

require('features.grep').setup(vimrc.context)

require('features.scrollbar').setup(vimrc.context)

require('features.ai').setup(vimrc.context)

-- Setup lazy.nvim
require('lazy-rtp')
require('lazy').setup({
  spec = vimrc.context.plugins,
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { 'oceanicnext' } },
  -- automatically check for plugin updates
  -- checker = { enabled = true },
  ui = {
    border = symbols.border.nvim_style,
  },
})
