local vimrc = require('vimrc')

local mod = {}

local map = vimrc.keymap

mod.setup = vimrc.make_setup(function(context)
  --- @type VimrcFeature
  local feature = {
    name = 'grep',
  }

  feature.plugins = {
    -- Fuzzy Finder (files, lsp, etc)
    -- {
    --   'nvim-telescope/telescope.nvim',
    --   cond = not vim.g.vscode,
    --   event = 'VimEnter',
    --   dependencies = {
    --     'nvim-lua/plenary.nvim',

    --     { -- If encountering errors, see telescope-fzf-native README for installation instructions
    --       'nvim-telescope/telescope-fzf-native.nvim',

    --       -- `build` is used to run some command when the plugin is installed/updated.
    --       -- This is only run then, not every time Neovim starts up.
    --       build = 'make',

    --       -- `cond` is a condition used to determine whether this plugin should be
    --       -- installed and loaded.
    --       cond = function()
    --         return vim.fn.executable('make') == 1
    --       end,
    --     },

    --     { 'nvim-telescope/telescope-ui-select.nvim' },

    --     { 'debugloop/telescope-undo.nvim' },

    --     -- Useful for getting pretty icons, but requires a Nerd Font.
    --     -- { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    --     -- { 'MunifTanjim/nui.nvim' },
    --   },
    --   opts = function()
    --     -- Adapted from https://github.com/nvim-telescope/telescope.nvim/blob/5972437de807c3bc101565175da66a1aa4f8707a/lua/telescope/actions/set.lua#L127
    --     local function wut(prompt_bufnr)
    --       local action_state = require('telescope.actions.state')

    --       local entry = action_state.get_selected_entry()
    --       if not entry then
    --         return
    --       end

    --       local filename, row, col

    --       if entry.path or entry.filename then
    --         filename = entry.path or entry.filename

    --         row = entry.row or entry.lnum
    --         col = entry.col
    --       elseif not entry.bufnr then
    --         local value = entry.value
    --         if not value then
    --           return
    --         end

    --         if type(value) == 'table' then
    --           value = entry.display
    --         end

    --         local sections = vim.split(value, ':')

    --         filename = sections[1]
    --         row = tonumber(sections[2])
    --         col = tonumber(sections[3])
    --       end

    --       local entry_bufnr = entry.bufnr

    --       require('telescope.pickers').on_close_prompt(prompt_bufnr)
    --       -- local picker = action_state.get_current_picker(prompt_bufnr)
    --       -- pcall(vim.api.nvim_set_current_win, picker.original_win_id)

    --       -- TODO Not sure which is better here.
    --       -- vim.api.nvim_feedkeys(
    --       --   vim.api.nvim_replace_termcodes('<ESC>', true, false, true),
    --       --   'n',
    --       --   true
    --       -- )
    --       vim.cmd('stopinsert')

    --       vimrc.go_to_file_or_open(filename, { row, col })
    --     end

    --     return {
    --       --  All the info you're looking for is in `:help telescope.setup()`
    --       pickers = {
    --         colorscheme = {
    --           enable_preview = true,
    --         },
    --       },

    --       defaults = vim.tbl_deep_extend(
    --         'force',
    --         {},
    --         require('telescope.themes').get_dropdown({
    --           mappings = {
    --             i = {
    --               -- ['<c-enter>'] = 'to_fuzzy_refine',
    --               ['<CR>'] = wut,
    --               ['<C-CR>'] = 'select_default',
    --               ['<S-CR>'] = 'select_vertical',
    --             },
    --             n = {
    --               ['<CR>'] = wut,
    --               ['<C-CR>'] = 'select_default',
    --               ['<S-CR>'] = 'select_vertical',
    --             },
    --           },
    --         })
    --       ),

    --       -- extensions = {
    --       --   -- Disabling due to the fact that codeactons doesn't work, and
    --       --   -- disabling just codeactons also doesn't work.
    --       --   -- https://github.com/nvim-telescope/telescope-ui-select.nvim/issues/44
    --       --   -- ['ui-select'] = {
    --       --   --   require('telescope.themes').get_dropdown(),
    --       --   -- },
    --       -- },
    --     }
    --   end,
    --   config = function(_, opts)
    --     -- Telescope is a fuzzy finder that comes with a lot of different things that
    --     -- it can fuzzy find! It's more than just a "file finder", it can search
    --     -- many different aspects of Neovim, your workspace, LSP, and more!
    --     --
    --     -- The easiest way to use Telescope, is to start by doing something like:
    --     --  :Telescope help_tags
    --     --
    --     -- After running this command, a window will open up and you're able to
    --     -- type in the prompt window. You'll see a list of `help_tags` options and
    --     -- a corresponding preview of the help.
    --     --
    --     -- Two important keymaps to use while in Telescope are:
    --     --  - Insert mode: <c-/>
    --     --  - Normal mode: ?
    --     --
    --     -- This opens a window that shows you all of the keymaps for the current
    --     -- Telescope picker. This is really useful to discover what Telescope can
    --     -- do as well as how to actually do it!

    --     -- [[ Configure Telescope ]]
    --     -- See `:help telescope` and `:help telescope.setup()`
    --     require('telescope').setup(opts)

    --     -- Enable Telescope extensions if they are installed
    --     pcall(require('telescope').load_extension, 'fzf')
    --     -- pcall(require('telescope').load_extension, 'ui-select')
    --     pcall(require('telescope').load_extension, 'undo')

    --     -- See `:help telescope.builtin`
    --     local builtin = require('telescope.builtin')
    --     vim.keymap.set(
    --       'n',
    --       '<C-p>',
    --       builtin.find_files,
    --       { desc = '[S]earch [F]iles' }
    --     )
    --     vim.keymap.set(
    --       'i',
    --       '<C-p>',
    --       builtin.find_files,
    --       { desc = '[S]earch [F]iles' }
    --     )
    --     if context.has_gui_running then
    --       if context.os == 'macos' then
    --         vim.keymap.set(
    --           'n',
    --           '<D-t>',
    --           builtin.find_files,
    --           { desc = '[S]earch [F]iles' }
    --         )
    --         vim.keymap.set(
    --           'i',
    --           '<D-t>',
    --           builtin.find_files,
    --           { desc = '[S]earch [F]iles' }
    --         )
    --         vim.keymap.set(
    --           'n',
    --           '<D-p>',
    --           builtin.find_files,
    --           { desc = '[S]earch [F]iles' }
    --         )
    --         vim.keymap.set(
    --           'i',
    --           '<D-p>',
    --           builtin.find_files,
    --           { desc = '[S]earch [F]iles' }
    --         )
    --       end
    --     end

    --     vim.keymap.set(
    --       'n',
    --       '<C-S-F>',
    --       builtin.live_grep,
    --       { desc = '[S]earch by [G]rep' }
    --     )
    --     if context.has_gui_running then
    --       if context.os == 'macos' then
    --         vim.keymap.set(
    --           'i',
    --           '<D-F>',
    --           builtin.live_grep,
    --           { desc = '[S]earch by [G]rep' }
    --         )
    --         vim.keymap.set(
    --           'n',
    --           '<D-F>',
    --           builtin.live_grep,
    --           { desc = '[S]earch by [G]rep' }
    --         )
    --       end
    --     end

    --     vim.keymap.set(
    --       'n',
    --       '<leader>sd',
    --       builtin.diagnostics,
    --       { desc = '[S]earch [D]iagnostics' }
    --     )
    --     vim.keymap.set(
    --       'n',
    --       '<leader>sr',
    --       builtin.resume,
    --       { desc = '[S]earch [R]esume' }
    --     )
    --     vim.keymap.set(
    --       'n',
    --       '<leader><leader>',
    --       builtin.buffers,
    --       { desc = '[ ] Find existing buffers' }
    --     )
    --   end,
    -- },

    {
      'folke/snacks.nvim',
      ---@type snacks.Config
      opts = {
        picker = {
          enabled = true,
          ui_select = false,

          matcher = {
            sort_empty = true,
            frecency = true,
            history_bonus = true,
          },

          sources = {
            git_grep = {
              ignorecase = true,
            },
          },

          jump = {
            reuse_win = true, -- reuse an existing window if the buffer is already open
            match = true, -- jump to the first match position. (useful for `lines`)
          },

          win = {
            input = {
              keys = {
                ['<CR>'] = { 'tabdrop', mode = { 'n', 'i' } },
                ['<C-CR>'] = { 'split', mode = { 'n', 'i' } },
                ['<S-CR>'] = { 'vsplit', mode = { 'n', 'i' } },
              },
            },

            list = {
              wo = {
                statuscolumn = '',
                signcolumn = 'no',
                number = false,
                foldcolumn = '0',
              },

              keys = {
                ['<CR>'] = 'tabdrop',
                ['<C-CR>'] = 'split',
                ['<S-CR>'] = 'vsplit',
              },
            },

            preview = {
              wo = {
                statuscolumn = '',
                signcolumn = 'no',
                number = false,
                foldcolumn = '0',
              },
            },
          },
        },
      },
      config = function(_, opts)
        require('picker_patches')
        local snacks = require('snacks')
        snacks.setup(opts)

        map('Find Files', '<C-p>', { 'n', 'i', 't' }, function()
          snacks.picker.git_files()
        end)
        if context.has_gui_running then
          if context.os == 'macos' then
            map('Find Files', '<D-t>', { 'n', 'i', 't' }, function()
              snacks.picker.git_files()
            end)
            map('Find Files', '<D-p>', { 'n', 'i', 't' }, function()
              snacks.picker.git_files()
            end)
          end
        end

        map('Search by Grep', '<C-S-F>', { 'n', 'i', 't' }, function()
          snacks.picker.git_grep()
        end)
        if context.has_gui_running then
          if context.os == 'macos' then
            map('Search by Grep', '<D-F>', { 'n', 'i', 't' }, function()
              snacks.picker.git_grep()
            end)
          end
        end

        map('Search Diagnostics', '<leader>sd', 'n', function()
          snacks.picker.diagnostics()
        end)

        map('Resume Search', '<leader>sr', 'n', function()
          snacks.picker.resume()
        end)

        map('Find Buffers', '<leader><leader>', 'n', function()
          snacks.picker.buffers()
        end)
      end,
    },
  }

  return feature
end)

return mod
