" QOL
Plug 'tpope/vim-surround'
Plug 'terryma/vim-multiple-cursors'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-eunuch'
Plug 'troydm/zoomwintab.vim'
Plug 'farmergreg/vim-lastplace'
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


" Things vim should just do
Plug 'michaeljsmith/vim-indent-object'
Plug 'nelstrom/vim-visual-star-search'
