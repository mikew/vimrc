local vimrc = require('vimrc')

local mod = {}

mod.setup = vimrc.make_setup(function(context)
  --- @type VimrcFeature
  local feature = {
    name = 'languages',
  }

  feature.plugins = {
    {
      'RRethy/nvim-treesitter-endwise',
      cond = not vim.g.vscode,
    },

    {
      'nvim-treesitter/nvim-treesitter',
      cond = not vim.g.vscode,
      version = false,
      build = ':TSUpdate',
      main = 'nvim-treesitter.configs',
      event = { 'VeryLazy' },
      -- load treesitter early when opening a file from the cmdline
      lazy = vim.fn.argc(-1) == 0,
      cmd = { 'TSUpdateSync', 'TSUpdate', 'TSInstall' },
      opts = {
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },

        indent = {
          enable = true,
        },

        ensure_installed = {
          'bash',
          'c',
          'diff',
          'dockerfile',
          'go',
          'graphql',
          'html',
          'javascript',
          'jsdoc',
          'json',
          'jsonc',
          'lua',
          'luadoc',
          'luap',
          'markdown',
          'markdown_inline',
          'printf',
          'python',
          'query',
          'regex',
          'ruby',
          'rust',
          'toml',
          'tsx',
          'typescript',
          'vim',
          'vimdoc',
          'xml',
          'yaml',
        },

        matchup = {
          enable = true,
        },

        endwise = {
          enable = true,
        },
      },
    },
  }

  return feature
end)

return mod
