local vimrc = require('vimrc')
local vimrc_pack = require('vimrc_pack')
local symbols = require('symbols')
local vimrc_colors = require('vimrc_colors')

local map = vimrc.keymap

vimrc.on_ui_ready(function(ui_context)
  if ui_context.ui == 'nvim-qt' then
    vimrc_pack.add({
      {
        'https://github.com/equalsraf/neovim-gui-shim',
        setup = function()
          vim.cmd('call GuiClipboard()')
        end,
      },
    })
  end
end)

-- Snacks is entirely too many things, split up across multiple features in
-- this repo. This initial bit just makes sure we don't enable any feature.
vimrc_pack.add({
  {
    'https://github.com/folke/snacks.nvim',
    data = {
      bigfile = { enabled = false },
      dashboard = { enabled = false },
      explorer = { enabled = false },
      indent = { enabled = false },
      input = { enabled = false },
      notifier = { enabled = false },
      picker = { enabled = false },
      quickfile = { enabled = false },
      scope = { enabled = false },
      scroll = { enabled = false },
      statuscolumn = { enabled = false },
      words = { enabled = false },
    },
    lazy = 'VimEnter',
    setup = function()
      require('snacks').setup(vimrc_pack.get_data_for('snacks.nvim'))
    end,
  },
})

vimrc_pack.add({
  {
    'https://github.com/RRethy/base16-nvim',
    lazy = 'Immediate',
    setup = function()
      vim.cmd('colorscheme base16-oceanicnext')

      local function apply_additional_highlights()
        local theme = {}

        theme.background = vimrc_colors.get_hl_color('Normal', 'bg')
          or '#000000'
        theme.background_alt = vimrc_colors.darken(theme.background, 0.3)

        theme.text_primary = vimrc_colors.get_hl_color('Normal', 'fg')
          or '#ffffff'
        theme.text_quiet1 =
          vimrc_colors.mix(theme.text_primary, theme.background, 0.5)
        theme.text_quiet2 =
          vimrc_colors.mix(theme.text_primary, theme.background, 0.8)

        vim.api.nvim_set_hl(0, 'VimrcNormalNC', {
          fg = theme.text_quiet1,
          bg = theme.background_alt,
          force = true,
        })
        vim.api.nvim_set_hl(0, 'FloatBorder', {
          fg = theme.text_quiet2,
          force = true,
        })
        vim.api.nvim_set_hl(0, 'WinSeparator', {
          fg = theme.text_quiet2,
          force = true,
        })

        vim.api.nvim_set_hl(0, 'LineNr', {
          link = 'CursorLineNr',
          force = true,
        })
        vim.api.nvim_set_hl(0, 'FoldColumn', {
          link = 'CursorLineNr',
          force = true,
        })
        vim.api.nvim_set_hl(0, 'SignColumn', {
          link = 'CursorLineNr',
          force = true,
        })

        vim.api.nvim_set_hl(0, 'NvimTreeIndentMarker', {
          fg = theme.text_quiet2,
          force = true,
        })

        vim.api.nvim_set_hl(0, 'IndentLine', {
          fg = theme.text_quiet2,
          force = true,
        })
        vim.api.nvim_set_hl(0, 'IndentLineCurrent', {
          fg = theme.text_quiet1,
          force = true,
        })
      end

      vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
        callback = function()
          apply_additional_highlights()
        end,
      })

      apply_additional_highlights()
    end,
  },
})

vimrc_pack.add({
  {
    'https://github.com/kylechui/nvim-surround',
    version = vim.version.range('*'),
    lazy = 'VimEnter',
    setup = function()
      require('nvim-surround').setup()
    end,
  },
})

vimrc_pack.add({
  {
    'https://github.com/michaeljsmith/vim-indent-object',
    lazy = 'VimEnter',
  },
})

-- Detect tabstop and shiftwidth automatically
vimrc_pack.add({ { 'https://github.com/tpope/vim-sleuth' } })

vimrc_pack.add({
  {
    'https://github.com/numToStr/Comment.nvim',
    lazy = 'VimEnter',
    setup = function()
      require('Comment').setup({
        ignore = '^(%s*)$',
      })
      vimrc.on_ui_ready(function(ui_context)
        if ui_context.has_gui and ui_context.os == 'macos' then
          map(
            'Toggle comment linewise',
            '<D-/>',
            'n',
            '<Plug>(comment_toggle_linewise_current)'
          )
          map(
            'Toggle comment linewise',
            '<D-/>',
            'i',
            '<C-o><Plug>(comment_toggle_linewise_current)'
          )
          map(
            'Toggle comment linewise',
            '<D-/>',
            'v',
            '<Plug>(comment_toggle_linewise_visual)gv'
          )
        else
          map(
            'Toggle comment linewise',
            '<C-/>',
            'n',
            '<Plug>(comment_toggle_linewise_current)'
          )
          map(
            'Toggle comment linewise',
            '<C-/>',
            'i',
            '<C-o><Plug>(comment_toggle_linewise_current)'
          )
          map(
            'Toggle comment linewise',
            '<C-/>',
            'v',
            '<Plug>(comment_toggle_linewise_visual)gv'
          )
        end
      end)
    end,
  },
})

vimrc_pack.add({
  {
    'https://github.com/windwp/nvim-autopairs',
    lazy = 'VimEnter',
    setup = function()
      require('nvim-autopairs').setup()
    end,
  },
})

vimrc_pack.add({
  {
    'https://github.com/nvimdev/indentmini.nvim',
    lazy = 'VimEnter',
    setup = function()
      require('indentmini').setup({
        char = symbols.indent.line,
      })
    end,
  },
})

vimrc_pack.add({
  {
    'https://github.com/RRethy/vim-illuminate',
    lazy = 'VimEnter',
    setup = function()
      require('illuminate').configure()
    end,
  },
})

vimrc_pack.add({
  {
    'https://github.com/luukvbaal/statuscol.nvim',
    setup = function()
      local builtin = require('statuscol.builtin')

      local ft_ignore = {
        'man',
        'help',
        'neo-tree',
        'starter',
        'TelescopePrompt',
        'Trouble',
        'NvimTree',
        'nvcheatsheet',
        'dapui_watches',
        'dap-repl',
        'dapui_console',
        'spectre_panel',
        'dapui_stacks',
        'dapui_breakpoints',
        'dapui_scopes',
        -- 'snacks_picker_list',
        -- 'snacks_picker_preview',
      }

      require('statuscol').setup({
        relculright = true,
        setopt = true,
        segments = {
          { text = { builtin.lnumfunc }, click = 'v:lua.ScLa' },

          {
            sign = {
              namespace = { 'diagnostic' },
              maxwidth = 1,
              colwidth = 1,
              auto = false,
            },
            click = 'v:lua.ScSa',
          },

          { text = { builtin.foldfunc }, click = 'v:lua.ScFa' },

          {
            sign = {
              namespace = { 'gitsign' },
              maxwidth = 1,
              colwidth = 1,
              auto = false,
            },
            click = 'v:lua.ScSa',
          },
        },
      })

      vim.api.nvim_create_autocmd('BufWinEnter', {
        callback = function()
          if vim.tbl_contains(ft_ignore, vim.bo.filetype) then
            -- Intentionally not using `vim.wo[event.winid]` here since it
            -- seems to mess up the options for windows opened from this
            -- window.
            vim.opt_local.statuscolumn = ''
            vim.opt_local.signcolumn = 'no'
            vim.opt_local.number = false
            vim.opt_local.foldcolumn = '0'
          end
        end,
      })
    end,
  },
})

vimrc_pack.add({
  {
    'https://github.com/andymass/vim-matchup',
    lazy = 'VimEnter',
    setup = function()
      require('match-up').setup({})
    end,
  },
})

vimrc_pack.add({
  {
    'https://github.com/nvim-lualine/lualine.nvim',
    setup = function()
      require('lualine').setup({
        options = {
          component_separators = { left = '|', right = '|' },
          section_separators = { left = '', right = '' },
        },

        sections = {
          lualine_a = { 'mode' },
          lualine_b = {
            'branch',
          },
          lualine_c = { 'filename' },

          lualine_x = { 'filetype' },
          lualine_y = {},
          lualine_z = { 'location' },
        },

        tabline = {
          lualine_a = {
            {
              'tabs',

              mode = 1,
              path = 0,
              max_length = function()
                return vim.o.columns
              end,

              --- @param fallback_name string
              --- @param fmt_context {
              --- buftype: string,
              --- current: boolean,
              --- file: string,
              --- filetype: string,
              --- first: boolean,
              --- last: boolean,
              --- options: table,
              --- tabId: integer,
              --- tabnr: integer,
              --- }
              fmt = function(fallback_name, fmt_context)
                local no_name = '[No Name]'

                local to_check = {
                  -- Start with the focused window.
                  vim.api.nvim_tabpage_get_win(fmt_context.tabId),
                }
                -- Then add all other windows in the tab.
                vim.list_extend(
                  to_check,
                  vim.api.nvim_tabpage_list_wins(fmt_context.tabId)
                )

                --- @param wininfo { bufnr: integer, winid: integer, bufname: string, buftype: string }
                local function should_skip(wininfo)
                  if
                    vim.tbl_contains(
                      { 'nofile', 'quickfix', 'help' },
                      wininfo.buftype
                    )
                  then
                    return true
                  end

                  if vimrc_pack.has_plugin('nvim-drawer') then
                    local drawer = require('nvim-drawer')

                    if drawer.find_instance_for_winid(wininfo.winid) then
                      return true
                    end
                  end
                end

                for _, winid in ipairs(to_check) do
                  local bufnr = vim.api.nvim_win_get_buf(winid)
                  local bufname =
                    vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':t')

                  if bufname == '' then
                    bufname = no_name
                  end

                  local wininfo = {
                    bufnr = bufnr,
                    winid = winid,
                    bufname = bufname,
                    buftype = vim.api.nvim_get_option_value('buftype', {
                      buf = bufnr,
                    }),
                  }

                  if not should_skip(wininfo) then
                    return wininfo.bufname
                  end
                end

                return no_name
              end,
            },
          },
        },
      })
    end,
  },
})

vimrc_pack.add({
  { 'https://github.com/kevinhwang91/promise-async' },
  {
    'https://github.com/kevinhwang91/nvim-ufo',
    lazy = 'VimEnter',
    setup = function()
      require('ufo').setup({
        provider_selector = function(bufnr, filetype, buftype)
          return { 'treesitter', 'indent' }
        end,
      })
    end,
  },
})
