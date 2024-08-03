local mod = {}

mod.plugins = {
  {
    'nvim-treesitter/nvim-treesitter',
    cond = not vim.g.vscode,
    version = false,
    build = ':TSUpdate',
    event = { 'VeryLazy' },
    -- load treesitter early when opening a file from the cmdline
    lazy = vim.fn.argc(-1) == 0,
    cmd = { 'TSUpdateSync', 'TSUpdate', 'TSInstall' },
    opts = {
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = true,
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
    },
    config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)
    end,
  },
}

return mod
