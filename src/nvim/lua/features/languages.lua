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
      -- load treesitter early when opening a file from the cmdline
      lazy = vim.fn.argc(-1) == 0,
      event = { 'VeryLazy' },
      build = ':TSUpdate',
      branch = 'main',

      opts = {
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },

        indent = {
          enable = true,
        },

        matchup = {
          enable = true,
        },

        endwise = {
          enable = true,
        },
      },

      config = function(_, opts)
        local parsers = {
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
        }
        require('nvim-treesitter').install(parsers)

        local all_fts = vim.list_extend({}, parsers)
        all_fts = vim.list_extend(all_fts, {
          'typescriptreact',
          'javascriptreact',
        })

        vim.api.nvim_create_autocmd('FileType', {
          pattern = all_fts,
          callback = function()
            -- Enables syntax highlighting and other treesitter features
            vim.treesitter.start()

            -- Enables treesitter based folds
            -- for more info on folds see `:help folds`
            -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'

            -- enables treesitter based indentation
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end,
        })
      end,
    },
  }

  return feature
end)

return mod
