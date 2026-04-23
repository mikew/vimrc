local vimrc_pack = require('vimrc_pack')

vimrc_pack.add({ { 'https://github.com/RRethy/nvim-treesitter-endwise' } })

-- vim.api.nvim_create_autocmd('PackChanged', {
--   callback = function(ev)
--     if ev.data.spec.name == 'nvim-treesitter' and ev.data.kind == 'update' then
--       if not ev.data.active then
--         vim.cmd.packadd('nvim-treesitter')
--       end
--       vim.cmd('TSUpdate')
--     end
--   end,
-- })

vimrc_pack.add({
  {
    'https://github.com/nvim-treesitter/nvim-treesitter',
    version = 'main',
    lazy = 'VimEnter',
    setup = function()
      --- @param bufnr integer
      local function start_treesitter(bufnr)
        -- Enables syntax highlighting and other treesitter features
        vim.treesitter.start(bufnr)

        -- Enables treesitter based folds
        -- for more info on folds see `:help folds`
        -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'

        -- enables treesitter based indentation
        -- vim.bo.indentexpr =
        --   "v:lua.require'nvim-treesitter'.indentexpr()"
      end

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

            start_treesitter(bufnr)
          end)
        end,
      })
    end,
  },
})

-- vimrc_pack.add({
--   {
--     'https://github.com/romus204/tree-sitter-manager.nvim',
--     lazy = 'VimEnter',
--     setup = function()
--       require('tree-sitter-manager').setup({
--         border = symbols.border.nvim_style,
--         auto_install = true,
--         highlight = true,
--         -- Default Options
--         -- ensure_installed = {}, -- list of parsers to install at the start of a neovim session
--         -- border = nil, -- border style for the window (e.g. "rounded", "single"), if nil, use the default border style defined by 'vim.o.winborder'. See :h 'winborder' for more info.
--         -- auto_install = false, -- if enabled, install missing parsers when editing a new file
--         -- highlight = true, -- treesitter highlighting is enabled by default
--         -- languages = {}, -- override or add new parser sources
--         -- parser_dir = vim.fn.stdpath("data") .. "/site/parser",
--         -- query_dir = vim.fn.stdpath("data") .. "/site/queries",
--       })

--       -- vim.api.nvim_create_autocmd('FileType', {
--       --   callback = function()
--       --     pcall(vim.treesitter.start)
--       --   end,
--       -- })
--     end,
--   },
-- })
