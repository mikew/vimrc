local vimrc = require('vimrc')
local symbols = require('symbols')

local mod = {}

mod.setup = vimrc.make_setup(function(context)
  local diagnostic_symbols = {
    Hint = symbols.diagnostics.hint,
    Info = symbols.diagnostics.info,
    Warn = symbols.diagnostics.warn,
    Error = symbols.diagnostics.error,
  }

  for name, symbol in pairs(diagnostic_symbols) do
    local hl = 'DiagnosticSign' .. name
    vim.fn.sign_define(hl, { text = symbol, numhl = hl, texthl = hl })
  end

  --- @type VimrcFeature
  local feature = {
    name = 'lsp',
  }

  feature.plugins = {
    {
      'mason-org/mason.nvim',
      cond = not vim.g.vscode,
      dependencies = {
        { 'mason-org/mason-lspconfig.nvim' },
        { 'neovim/nvim-lspconfig' },
        {
          'nvimtools/none-ls.nvim',
          dependencies = {
            { 'nvim-lua/plenary.nvim' },
          },
        },
        { 'nvimtools/none-ls-extras.nvim' },
      },
      opts = {
        ui = {
          border = symbols.border.nvim_style,
        },
      },
      config = function(_, opts)
        -- By default, Neovim doesn't support everything that is in the LSP specification.
        -- When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
        -- So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
        local base_capabilities = vim.lsp.protocol.make_client_capabilities()
        if vimrc.has_feature('completion') then
          base_capabilities =
            require('blink.cmp').get_lsp_capabilities(base_capabilities)
        end

        -- Enable the following language servers
        -- Feel free to add/remove any LSPs that you want here. They will automatically be installed.
        --
        -- Add any additional override configuration in the following tables. Available keys are:
        -- - cmd (table): Override the default command used to start the server
        -- - filetypes (table): Override the default list of associated filetypes for the server
        -- - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
        -- - settings (table): Override the default settings passed when initializing the server.
        --       For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
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
              client.server_capabilities.document_formatting = false
              client.server_capabilities.document_range_formatting = false
            end,
            -- cmd = {...},
            -- filetypes = { ...},
            -- capabilities = {},
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
        require('mason').setup(opts)

        -- You can add other tools here that you want Mason to install
        -- for you, so that they are available from within Neovim.
        -- local ensure_installed = vim.tbl_keys(servers or {})
        -- vim.list_extend(ensure_installed, {
        --   'stylua', -- Used to format Lua code
        -- })
        -- require('mason-tool-installer').setup({ ensure_installed = ensure_installed })

        -- Work around the deprecation of `vim.lsp.with`.
        -- https://github.com/nvim-telescope/telescope.nvim/issues/3436#issuecomment-2775658101
        local original_hover = vim.lsp.buf.hover
        vim.lsp.buf.hover = function(config)
          original_hover(vim.tbl_deep_extend('force', {}, {
            border = symbols.border.nvim_style,
          }, config or {}))
        end

        local original_signature_help = vim.lsp.buf.signature_help
        vim.lsp.buf.signature_help = function(config)
          original_signature_help(vim.tbl_deep_extend('force', {}, {
            border = symbols.border.nvim_style,
          }, config or {}))
        end

        require('mason-lspconfig').setup({
          ensure_installed = {},
          automatic_installation = {},
          handlers = {
            function(server_name)
              local server = servers[server_name] or {}

              -- This handles overriding only values explicitly passed
              -- by the server configuration above. Useful when disabling
              -- certain features of an LSP (for example, turning off formatting for tsserver)
              server.handlers = vim.tbl_deep_extend('force', {}, {
                -- ['textDocument/signatureHelp'] = vim.lsp.with(
                --   vim.lsp.handlers.signature_help,
                --   { border = symbols.border.nvim_style }
                -- ),
              }, server.handlers or {})

              server.capabilities = vim.tbl_deep_extend(
                'force',
                {},
                base_capabilities,
                server.capabilities or {}
              )

              require('lspconfig')[server_name].setup(server)
            end,
          },
        })

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

            --- @param keys string
            --- @param func function
            --- @param desc string
            --- @param mode? string
            local map = function(keys, func, desc, mode)
              mode = mode or 'n'

              vim.keymap.set(
                mode,
                keys,
                func,
                { buffer = event.buf, desc = 'LSP: ' .. desc }
              )
            end

            if vimrc.has_feature('grep') then
              -- Jump to the definition of the word under your cursor.
              -- This is where a variable was first declared, or where a function is defined, etc.
              -- To jump back, press <C-t>.
              map('gd', function(...)
                require('telescope.builtin').lsp_definitions(...)
              end, '[G]oto [D]efinition')

              -- Find references for the word under your cursor.
              map('gr', function(...)
                require('telescope.builtin').lsp_references(...)
              end, '[G]oto [R]eferences')

              -- Jump to the implementation of the word under your cursor.
              -- Useful when your language has ways of declaring types without an actual implementation.
              map('gI', function(...)
                require('telescope.builtin').lsp_implementations(...)
              end, '[G]oto [I]mplementation')

              -- Jump to the type of the word under your cursor.
              -- Useful when you're not sure what type a variable is and you want to see
              -- the definition of its *type*, not where it was *defined*.
              map('<leader>D', function(...)
                require('telescope.builtin').lsp_type_definitions(...)
              end, 'Type [D]efinition')

              -- Fuzzy find all the symbols in your current document.
              -- Symbols are things like variables, functions, types, etc.
              map('<leader>ds', function(...)
                require('telescope.builtin').lsp_document_symbols(...)
              end, '[D]ocument [S]ymbols')

              -- Fuzzy find all the symbols in your current workspace.
              -- Similar to document symbols, except searches over your entire project.
              map('<leader>ws', function(...)
                require('telescope.builtin').lsp_dynamic_workspace_symbols(...)
              end, '[W]orkspace [S]ymbols')
            end

            -- Rename the variable under your cursor.
            -- Most Language Servers support renaming across files, etc.
            map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
            map('<F2>', vim.lsp.buf.rename, '[R]e[n]ame')

            -- Execute a code action, usually your cursor needs to be on top of an error
            -- or a suggestion from your LSP for this to activate.
            map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
            map('<D-.>', vim.lsp.buf.code_action, '[C]ode [A]ction')
            map('<D-.>', vim.lsp.buf.code_action, '[C]ode [A]ction', 'i')
            map('<C-.>', vim.lsp.buf.code_action, '[C]ode [A]ction')
            map('<C-.>', vim.lsp.buf.code_action, '[C]ode [A]ction', 'i')

            -- WARN: This is not Goto Definition, this is Goto Declaration.
            --  For example, in C this would take you to the header.
            map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

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
              local highlight_augroup =
                vimrc.create_augroup('lsp-highlight', false)

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
                    -- group = 'kickstart-lsp-highlight',
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
              map('<leader>th', function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({
                  bufnr = event.buf,
                }))
              end, '[T]oggle Inlay [H]ints')
            end
          end,
        })

        vim.api.nvim_create_user_command(
          'SaveWithoutFormatting',
          'let g:_vimrc_disable_format_on_write = 1 | w',
          {}
        )

        vim.api.nvim_create_autocmd('BufWritePre', {
          callback = function()
            if not vim.g._vimrc_disable_format_on_write then
              local view = vim.fn.winsaveview()
              vim.lsp.buf.format({
                timeout_ms = 10000,
              })
              vim.fn.winrestview(view)
            end

            vim.g._vimrc_disable_format_on_write = false
          end,
        })
      end,
    },

    {
      'folke/lazydev.nvim',
      cond = not vim.g.vscode,
      ft = 'lua', -- only load on lua files
      opts = {},
    },
  }

  return feature
end)

return mod
