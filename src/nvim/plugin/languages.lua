local vimrc_pack = require('vimrc_pack')

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

vimrc_pack.add({ { 'https://github.com/RRethy/nvim-treesitter-endwise' } })

vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    if ev.data.spec.name == 'nvim-treesitter' and ev.data.kind == 'update' then
      if not ev.data.active then
        vim.cmd.packadd('nvim-treesitter')
      end
      vim.cmd('TSUpdate')
    end
  end,
})

vimrc_pack.add({
  {
    'https://github.com/nvim-treesitter/nvim-treesitter',
    version = 'main',
    lazy = true,
    setup = function()
      local all_parsers = require('nvim-treesitter').get_available()
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          local bufnr = args.buf
          local vim_filetype = args.match

          local ts_lang = vim.treesitter.language.get_lang(vim_filetype)
          if not ts_lang or not vim.tbl_contains(all_parsers, ts_lang) then
            return
          end

          require('nvim-treesitter').install(ts_lang):await(function(_, success)
            if not success then
              return
            end

            start_treesitter(bufnr, vim_filetype, ts_lang)
          end)
        end,
      })
    end,
  },
})
