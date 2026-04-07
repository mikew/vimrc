local vimrc = require('vimrc')

local mod = {}

mod.setup = vimrc.make_setup(function()
  --- @type VimrcFeature
  local feature = {
    name = 'languages',
  }

  --- @param bufnr integer
  --- @param vim_filetype string
  --- @param ts_lang string
  local function start_treesitter(bufnr, vim_filetype, ts_lang)
    -- Enables syntax highlighting and other treesitter features
    vim.treesitter.start(bufnr, ts_lang)

    -- Enables treesitter based folds
    -- for more info on folds see `:help folds`
    -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'

    -- enables treesitter based indentation
    -- vim.bo.indentexpr =
    --   "v:lua.require'nvim-treesitter'.indentexpr()"
  end

  feature.plugins = {
    {
      'RRethy/nvim-treesitter-endwise',
      cond = not vim.g.vscode,
    },

    {
      'nvim-treesitter/nvim-treesitter',
      cond = not vim.g.vscode,
      -- load treesitter early when opening a file from the cmdline
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

      -- Either use a predefined list of languages ...
      -- config = function()
      --   local parsers = {
      --     'bash',
      --     'c',
      --     'diff',
      --     'dockerfile',
      --     'go',
      --     'graphql',
      --     'html',
      --     'javascript',
      --     'jsdoc',
      --     'json',
      --     'lua',
      --     'luadoc',
      --     'luap',
      --     'markdown',
      --     'markdown_inline',
      --     'printf',
      --     'python',
      --     'query',
      --     'regex',
      --     'ruby',
      --     'rust',
      --     'toml',
      --     'tsx',
      --     'typescript',
      --     'vim',
      --     'vimdoc',
      --     'xml',
      --     'yaml',
      --   }
      --   require('nvim-treesitter').install(parsers)

      --   local all_parsers = require('nvim-treesitter').get_available()
      --   vim.api.nvim_create_autocmd('FileType', {
      --     callback = function(args)
      --       local bufnr = args.buf
      --       local vim_filetype = args.match

      --       local ts_lang = vim.treesitter.language.get_lang(vim_filetype)
      --       if not ts_lang or not vim.tbl_contains(all_parsers, ts_lang) then
      --         return
      --       end

      --       local installed_parsers = require('nvim-treesitter').get_installed()
      --       if not vim.tbl_contains(installed_parsers, ts_lang) then
      --         return
      --       end

      --       start_treesitter(bufnr, vim_filetype, ts_lang)
      --     end,
      --   })
      -- end,

      -- ... or automatically install parsers.
      config = function()
        local all_parsers = require('nvim-treesitter').get_available()
        vim.api.nvim_create_autocmd('FileType', {
          callback = function(args)
            local bufnr = args.buf
            local vim_filetype = args.match

            local ts_lang = vim.treesitter.language.get_lang(vim_filetype)
            if not ts_lang or not vim.tbl_contains(all_parsers, ts_lang) then
              return
            end

            require('nvim-treesitter')
              .install(ts_lang)
              :await(function(_, success)
                if not success then
                  return
                end

                start_treesitter(bufnr, vim_filetype, ts_lang)
              end)
          end,
        })
      end,
    },
  }

  return feature
end)

return mod
