" QOL
Plug 'tpope/vim-surround'
Plug 'terryma/vim-multiple-cursors'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-eunuch'
Plug 'rchicoli/vim-zoomwin'
Plug 'ntpeters/vim-better-whitespace'
let g:better_whitespace_operator = ''

Plug 'chrisbra/Colorizer'
let g:colorizer_skip_comments = 1
let g:colorizer_auto_filetype = join([
      \ 'css',
      \ 'html',
      \ 'javascript',
      \ 'javascriptreact',
      \ 'javascript.jsx',
      \ 'typescript',
      \ 'typescriptreact',
      \ 'typescript.jsx',
      \ ], ',')

Plug 'dominikduda/vim_current_word'
let g:vim_current_word#highlight_current_word = 0
let g:vim_current_word#highlight_delay = 500
let g:vim_current_word#highlight_only_in_focused_window = 1
autocmd BufAdd NERD_tree_* :let b:vim_current_word_disabled_in_this_buffer = 1
autocmd VimEnter * hi CurrentWordTwins ctermbg=8 guibg=#505050

" Things vim should just do
Plug 'michaeljsmith/vim-indent-object'
Plug 'nelstrom/vim-visual-star-search'
