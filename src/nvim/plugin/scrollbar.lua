local vimrc = require('vimrc')
local vimrc_pack = require('vimrc_pack')
local symbols = require('symbols')

if vimrc.is_feature_disabled('scrollbar') then
  return
end

vimrc_pack.add({
  {
    'https://github.com/dstein64/nvim-scrollview',
    setup = function()
      require('scrollview').setup({
        excluded_filetypes = {
          'NvimTree',
        },

        -- current_only = true,
        always_show = true,
        signs_on_startup = {
          'conflicts',
          'cursor',
          'diagnostics',
          'search',
        },

        diagnostics_hint_symbol = symbols.diagnostics.hint,
        diagnostics_info_symbol = symbols.diagnostics.info,
        diagnostics_warn_symbol = symbols.diagnostics.warn,
        diagnostics_error_symbol = symbols.diagnostics.error,
      })

      if vimrc_pack.has_plugin('gitsigns.nvim') then
        require('scrollview.contrib.gitsigns').setup()
      end
    end,
  },
})
