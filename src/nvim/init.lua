local vimrc = require('vimrc')

vim.api.nvim_create_user_command('BetterTabclose', function(args)
  vimrc.better_tabclose(tonumber(args.args))
end, { nargs = 1 })

vim.api.nvim_create_autocmd('WinClosed', {
  callback = function(event)
    local drawer = require('nvim-drawer')

    --- @type integer
    --- @diagnostic disable-next-line: assign-type-mismatch
    local closing_window_id = tonumber(event.match)
    if not vim.api.nvim_win_is_valid(closing_window_id) then
      return
    end

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

-- gui loading
--- @type table<integer, boolean>
local uis_already_handled = {}
vim.api.nvim_create_autocmd('UIEnter', {
  group = vimrc.create_augroup('detect_ui'),
  callback = function(event)
    local function try_latest_ui()
      -- For some reason `event.data` is nil.
      -- local chan = event.data.chan
      -- So instead loop through all the channels, finding the latest where
      -- `client.type` is `ui`.
      --- @type integer?
      local chan
      for _, c in pairs(vim.api.nvim_list_chans()) do
        if
          c.client
          and c.client.type == 'ui'
          and not uis_already_handled[c.id]
        then
          chan = c.id
        end
      end

      if not chan then
        vim.schedule(try_latest_ui)
        return
      end

      uis_already_handled[chan] = true

      local uienter_chan = vim.api.nvim_get_chan_info(chan)

      --- @type VimrcUiContext
      local ui_context = {
        ui = '',
        os = '',
        has_gui = false,
      }

      if uienter_chan.client then
        ui_context.ui = uienter_chan.client.name
      end

      -- If we're in an nvrh session we can get the client OS from the channel.
      if _G._nvrh then
        for _, c in pairs(vim.api.nvim_list_chans()) do
          if
            c.client
            and c.client.name == 'nvrh'
            and c.client.attributes
            and c.client.attributes.nvrh_assumed_ui_channel == tostring(chan)
          then
            local nvrh_client_os = c.client.attributes.nvrh_client_os
            if nvrh_client_os == 'darwin' then
              nvrh_client_os = 'macos'
            end
            ui_context.os = nvrh_client_os

            break
          end
        end
      else
        -- Or determine the OS ourselves.
        ui_context.os = vimrc.determine_os()
      end

      vim.schedule(function()
        if ui_context.has_gui then
          require('ginit').setup(ui_context)
        end

        vimrc.run_ui_ready_callbacks(ui_context)
      end)
    end

    try_latest_ui()
  end,
})
