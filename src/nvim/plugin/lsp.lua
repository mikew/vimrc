local vimrc = require('vimrc')
local symbols = require('symbols')

local map = vimrc.keymap

vim.pack.add({
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/mason-org/mason-lspconfig.nvim',
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvimtools/none-ls.nvim',
  'https://github.com/nvimtools/none-ls-extras.nvim',
  'https://github.com/b0o/schemastore.nvim',
  'https://github.com/antosha417/nvim-lsp-file-operations',
})
vimrc.setup_plugin_lazy(function()
  -- By default, Neovim doesn't support everything that is in the LSP specification.
  -- When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
  -- So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
  local base_capabilities = vim.lsp.protocol.make_client_capabilities()
  if vimrc.has_plugin('blink.cmp') then
    base_capabilities = require('blink.cmp').get_lsp_capabilities(nil, true)
  end

  base_capabilities = vim.tbl_deep_extend(
    'force',
    {},
    base_capabilities,
    require('lsp-file-operations').default_capabilities()
  )

  -- Enable the following language servers
  -- Feel free to add/remove any LSPs that you want here. They will automatically be installed.
  --
  -- Add any additional override configuration in the following tables. Available keys are:
  -- - cmd (table): Override the default command used to start the server
  -- - filetypes (table): Override the default list of associated filetypes for the server
  -- - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
  -- - settings (table): Override the default settings passed when initializing the server.
  --       For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
  ---@type table<string, vim.lsp.Config>
  local servers = {
    -- clangd = {},
    -- gopls = {},
    -- pyright = {},
    -- rust_analyzer = {},
    -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
    --
    -- Some languages (like typescript) have entire language plugins that can be useful:
    -- https://github.com/pmizio/typescript-tools.nvim
    --
    -- But for many setups, the LSP (`tsserver`) will work just fine
    tsserver = {
      on_attach = function(client)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
      end,
    },

    vtsls = {
      on_attach = function(client)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
      end,
    },

    lua_ls = {
      on_attach = function(client)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
      end,
      -- settings = {
      --   Lua = {
      --     completion = {
      --       callSnippet = 'Replace',
      --     },
      --     -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
      --     -- diagnostics = { disable = { 'missing-fields' } },
      --   },
      -- },
    },

    tsgo = {
      on_attach = function(client)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
      end,
      filetypes = {
        'javascript',
        'javascriptreact',
        'javascript.jsx',
        'typescript',
        'typescriptreact',
        'typescript.tsx',
      },
      root_markers = {
        'tsconfig.json',
        'jsconfig.json',
        'package.json',
        '.git',
        'tsconfig.base.json',
      },
    },

    eslint = {
      filetypes = {
        'javascript',
        'javascriptreact',
        'javascript.jsx',
        'typescript',
        'typescriptreact',
        'typescript.tsx',
        'graphql',
      },
    },

    graphql = {
      filetypes = {
        'javascript',
        'javascriptreact',
        'javascript.jsx',
        'typescript',
        'typescriptreact',
        'typescript.tsx',
        'graphql',
      },
    },

    jsonls = {
      on_attach = function(client)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
      end,
      settings = {
        json = {
          schemas = require('schemastore').json.schemas(),
          validate = {
            -- https://github.com/b0o/SchemaStore.nvim/issues/8
            enable = true,
          },
        },
      },
    },

    yamlls = {
      format = {
        enable = false,
      },

      settings = {
        yaml = {
          schemaStore = {
            -- You must disable built-in schemaStore support if you want to use
            -- this plugin and its advanced options like `ignore`.
            enable = false,
            -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
            url = '',
          },
          schemas = require('schemastore').yaml.schemas(),
        },
      },
    },
  }

  local disabled_buftypes = {}
  local disabled_filetypes = {
    'NvimTree',
  }

  -- Ensure the servers and tools above are installed
  -- To check the current status of installed tools and/or manually install
  -- other tools, you can run
  --     :Mason
  --
  -- You can press `g?` for help in this menu.
  require('mason').setup({
    ui = {
      border = symbols.border.nvim_style,
    },
  })

  -- Work around the deprecation of `vim.lsp.with`.
  local original_open_floating_preview = vim.lsp.util.open_floating_preview
  vim.lsp.util.open_floating_preview = function(contents, syntax, fn_opts)
    fn_opts = vim.tbl_deep_extend('force', {
      border = symbols.border.nvim_style,
    }, fn_opts or {})

    local bufnr, winid =
      original_open_floating_preview(contents, syntax, fn_opts)

    -- This breaks single-line floating previews. They are wrapped in
    -- markdown codeblocks and the calculation seems to assume
    -- `conceallevel = 2` behaviour.
    -- vim.wo[winid].conceallevel = 0

    return bufnr, winid
  end

  require('mason-lspconfig').setup()

  -- The following loop will configure each server with the capabilities we defined above.
  -- This will ensure that all servers have the same base configuration, but also
  -- allow for server-specific overrides.
  for server_name, server_config in pairs(servers) do
    server_config.capabilities = vim.tbl_deep_extend(
      'force',
      {},
      base_capabilities,
      server_config.capabilities or {}
    )
    vim.lsp.config(server_name, server_config)
  end

  local null_ls = require('null-ls')
  null_ls.setup({
    sources = {
      null_ls.builtins.formatting.stylua,
      null_ls.builtins.formatting.prettier,

      null_ls.builtins.diagnostics.codespell.with({
        disabled_filetypes = disabled_filetypes,
      }),

      -- eslint is not needed with null-ls when using eslint-lsp.
    },
  })

  -- This function gets run when an LSP attaches to a particular buffer.
  -- That is to say, every time a new file is opened that is associated with
  -- an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
  -- function will be executed to configure the current buffer.
  -- This is called for each LSP.
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vimrc.create_augroup('lsp-attach'),
    callback = function(event)
      local buftype = vim.bo.buftype
      local buf_filetype = vim.bo.filetype

      if
        vim.tbl_contains(disabled_filetypes, buf_filetype)
        or vim.tbl_contains(disabled_buftypes, buftype)
      then
        return
      end

      if vimrc.has_plugin('snacks.nvim') then
        -- Jump to the definition of the word under your cursor.
        -- This is where a variable was first declared, or where a function is defined, etc.
        -- To jump back, press <C-t>.
        map('Goto Definition', 'gd', 'n', function()
          Snacks.picker.lsp_definitions()
        end)

        -- Find references for the word under your cursor.
        map('Goto References', 'gr', 'n', function()
          Snacks.picker.lsp_references()
        end)

        -- Jump to the implementation of the word under your cursor.
        -- Useful when your language has ways of declaring types without an actual implementation.
        map('Goto Implementation', 'gI', 'n', function()
          Snacks.picker.lsp_implementations()
        end)

        -- Jump to the type of the word under your cursor.
        -- Useful when you're not sure what type a variable is and you want to see
        -- the definition of its *type*, not where it was *defined*.
        map('Type Definition', '<leader>D', 'n', function()
          Snacks.picker.lsp_type_definitions()
        end)

        -- Fuzzy find all the symbols in your current document.
        -- Symbols are things like variables, functions, types, etc.
        map('Document Symbols', '<leader>ds', 'n', function()
          Snacks.picker.lsp_symbols()
        end)

        -- Fuzzy find all the symbols in your current workspace.
        -- Similar to document symbols, except searches over your entire project.
        map('Workspace Symbols', '<leader>ws', 'n', function()
          Snacks.picker.lsp_workspace_symbols()
        end)
      end

      -- Rename the variable under your cursor.
      -- Most Language Servers support renaming across files, etc.
      map('Rename', '<leader>rn', 'n', vim.lsp.buf.rename)
      map('Rename', '<F2>', 'n', vim.lsp.buf.rename)

      -- Execute a code action, usually your cursor needs to be on top of an error
      -- or a suggestion from your LSP for this to activate.
      map('Code Action', '<leader>ca', 'n', vim.lsp.buf.code_action)
      map('Code Action', '<D-.>', { 'n', 'i' }, vim.lsp.buf.code_action)
      map('Code Action', '<C-.>', { 'n', 'i' }, vim.lsp.buf.code_action)

      -- WARN: This is not Goto Definition, this is Goto Declaration.
      --  For example, in C this would take you to the header.
      map('Goto Declaration', 'gD', 'n', vim.lsp.buf.declaration)

      -- The following two autocommands are used to highlight references of the
      -- word under your cursor when your cursor rests there for a little while.
      -- See `:help CursorHold` for information about when this is executed
      --
      -- When you move your cursor, the highlights will be cleared (the second autocommand).
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      if
        client
        and client:supports_method(
          vim.lsp.protocol.Methods.textDocument_documentHighlight
        )
      then
        local highlight_augroup = vimrc.create_augroup('lsp-highlight', false)

        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.document_highlight,
        })

        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.clear_references,
        })

        vim.api.nvim_create_autocmd('LspDetach', {
          group = vimrc.create_augroup('lsp-detach'),
          callback = function(lsp_detach_event)
            vim.lsp.buf.clear_references()
            vim.api.nvim_clear_autocmds({
              group = highlight_augroup,
              buffer = lsp_detach_event.buf,
            })
          end,
        })
      end

      -- The following code creates a keymap to toggle inlay hints in your
      -- code, if the language server you are using supports them
      --
      -- This may be unwanted, since they displace some of your code
      if
        client
        and client:supports_method(
          vim.lsp.protocol.Methods.textDocument_inlayHint
        )
      then
        map('Toggle Inlay Hints', '<leader>th', 'n', function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({
            bufnr = event.buf,
          }))
        end)
      end

      vim.lsp.semantic_tokens.enable(false)
    end,
  })

  vim.api.nvim_create_user_command(
    'SaveWithoutFormatting',
    'let g:_vimrc_disable_format_on_write = 1 | w',
    {}
  )

  local function lsp_format()
    local view = vim.fn.winsaveview()
    vim.lsp.buf.format({
      timeout_ms = 10000,
    })
    vim.fn.winrestview(view)
  end

  vim.api.nvim_create_user_command('LspFormat', function()
    lsp_format()
  end, {})

  vim.api.nvim_create_autocmd('BufWritePre', {
    callback = function()
      if not vim.g._vimrc_disable_format_on_write then
        pcall(vim.cmd.undojoin)
        lsp_format()
      end

      vim.g._vimrc_disable_format_on_write = false
    end,
  })
end)

vim.pack.add({ 'https://github.com/folke/lazydev.nvim' })
vimrc.setup_plugin_lazy(function()
  require('lazydev').setup({})
end)
