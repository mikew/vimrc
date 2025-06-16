local vimrc = require('vimrc')
local symbols = require('symbols')

local mod = {}

mod.setup = vimrc.make_setup(function(context)
  --- @type VimrcFeature
  local feature = {
    name = 'completion',
  }

  feature.plugins = {
    {
      'saghen/blink.cmp',
      cond = not vim.g.vscode,
      version = '1.*',
      event = 'VimEnter',

      ---@module 'blink.cmp'
      ---@type blink.cmp.Config
      opts = {
        keymap = {
          -- 'default' (recommended) for mappings similar to built-in completions
          --   <c-y> to accept ([y]es) the completion.
          --    This will auto-import if your LSP supports it.
          --    This will expand snippets if the LSP sent a snippet.
          -- 'super-tab' for tab to accept
          -- 'enter' for enter to accept
          -- 'none' for no mappings
          --
          -- For an understanding of why the 'default' preset is recommended,
          -- you will need to read `:help ins-completion`
          --
          -- No, but seriously. Please read `:help ins-completion`, it is really good!
          --
          -- All presets have the following mappings:
          -- <tab>/<s-tab>: move to right/left of your snippet expansion
          -- <c-space>: Open menu or open docs if already open
          -- <c-n>/<c-p> or <up>/<down>: Select next/previous item
          -- <c-e>: Hide menu
          -- <c-k>: Toggle signature help
          --
          -- See :h blink-cmp-config-keymap for defining your own keymap
          preset = 'none',
          ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
          ['<CR>'] = {
            -- TODO Might want to check out `select_and_accept`.
            'accept',
            'fallback',
          },
          ['<Up>'] = { 'select_prev', 'fallback' },
          ['<Down>'] = { 'select_next', 'fallback' },
          ['<Tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
          ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },

          -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
          --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
        },

        appearance = {
          -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
          -- Adjusts spacing to ensure icons are aligned
          nerd_font_variant = 'mono',
        },

        completion = {
          menu = {
            border = symbols.border.nvim_style,
          },

          -- By default, you may press `<c-space>` to show the documentation.
          -- Optionally, set `auto_show = true` to show the documentation after a delay.
          documentation = {
            auto_show = false,
            auto_show_delay_ms = 500,
            border = symbols.border.nvim_style,
          },

          list = {
            selection = {
              preselect = false,
              auto_insert = true,
            },
          },
        },

        sources = {
          default = { 'lsp', 'path', 'buffer', 'lazydev' },

          providers = {
            lazydev = {
              module = 'lazydev.integrations.blink',
              score_offset = 100,
            },

            buffer = {
              opts = {
                -- get all buffers, even ones like neo-tree
                get_bufnrs = vim.api.nvim_list_bufs,
              },
            },
          },
        },

        -- snippets = { preset = 'luasnip' },

        -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
        -- which automatically downloads a prebuilt binary when enabled.
        --
        -- By default, we use the Lua implementation instead, but you may enable
        -- the rust implementation via `'prefer_rust_with_warning'`
        --
        -- See :h blink-cmp-config-fuzzy for more information
        fuzzy = { implementation = 'prefer_rust' },

        -- Shows a signature help window while you type arguments for a function
        signature = {
          enabled = true,
          window = { border = 'single' },
        },

        cmdline = {
          keymap = {
            -- preset = 'inherit',
            -- ['<Tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
            -- ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
            -- Just accept, don't also run the command.
            ['<CR>'] = { 'accept', 'fallback' },
            -- Just hide the menu, don't exit the command line.
            ['<ESC>'] = { 'hide', 'fallback' },
            ['<Up>'] = { 'select_prev', 'fallback' },
            ['<Down>'] = { 'select_next', 'fallback' },
          },

          completion = {
            menu = {
              auto_show = false,
            },
          },
        },
      },
    },
  }

  return feature
end)

return mod
