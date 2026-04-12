local vimrc = require('vimrc')
local symbols = require('symbols')

require('features.editor').setup(vimrc.context)

require('features.languages').setup(vimrc.context)

require('features.scm').setup(vimrc.context)

require('features.lsp').setup(vimrc.context)

require('features.completion').setup(vimrc.context)

require('features.drawer').setup(vimrc.context)

require('features.grep').setup(vimrc.context)

require('features.scrollbar').setup(vimrc.context)

require('features.ai').setup(vimrc.context)

-- Setup lazy.nvim
require('lazy-rtp')
require('lazy').setup({
  spec = vimrc.context.plugins,
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { 'base16-oceanicnext' } },
  -- automatically check for plugin updates
  -- checker = { enabled = true },
  ui = {
    border = symbols.border.nvim_style,
  },
})

vim.api.nvim_create_user_command('BetterTabclose', function(args)
  vimrc.better_tabclose(tonumber(args.args))
end, { nargs = 1 })

vim.api.nvim_create_autocmd('WinClosed', {
  callback = function(event)
    local drawer = require('nvim-drawer')

    --- @type integer
    --- @diagnostic disable-next-line: assign-type-mismatch
    local closing_window_id = tonumber(event.match)
    local closing_instance = drawer.find_instance_for_winid(closing_window_id)

    if closing_instance then
      return
    end

    local bufnr_closed = vim.api.nvim_win_get_buf(closing_window_id)

    -- If the buffer is open in any other window, do nothing.
    for _, winid in ipairs(vim.api.nvim_list_wins()) do
      if winid ~= closing_window_id then
        local bufnr = vim.api.nvim_win_get_buf(winid)
        if bufnr == bufnr_closed then
          return
        end
      end
    end

    -- Otherwise delete the buffer.
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(bufnr_closed) then
        vim.api.nvim_buf_delete(bufnr_closed, { force = true })
      end
    end)
  end,
})
