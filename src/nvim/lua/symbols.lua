local border_symbols = {
  top_left = '╭',
  top = '─',
  top_right = '╮',

  left = '│',
  right = '│',

  bottom_left = '╰',
  bottom = '─',
  bottom_right = '╯',

  top_joiner = '┬',
  bottom_joiner = '┴',
  left_joiner = '├',
  right_joiner = '┤',
}

local symbols = {
  diagnostics = {
    hint = 'ℹ',
    info = 'ℹ',
    warn = '⚠',
    error = '⚠',
  },

  generic = {
    arrow_right_solid = '▶',
    arrow_right = '▷',
    arrow_down_solid = '▼',
    arrow_down = '▽',
    symlink = '↩',
    star = '★',
    hidden = '乚',
  },

  git = {
    changes = '~',
    staged = '✓',
    renamed = '➜',
    untracked = '★',
    deleted = '-',
    ignored = '◌',
  },

  indent = {
    line = '┊',
  },

  border = {
    symbols = border_symbols,
    -- nvim_style = 'rounded',
    nvim_style = {
      border_symbols.top_left,
      border_symbols.top,
      border_symbols.top_right,
      border_symbols.right,
      border_symbols.bottom_right,
      border_symbols.bottom,
      border_symbols.bottom_left,
      border_symbols.left,
    },
  },
}

return symbols
