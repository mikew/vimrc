Plug 'itchyny/lightline.vim'
Plug 'itchyny/vim-gitbranch'
set laststatus=2
let g:lightline = {
      \ 'colorscheme': 'Tomorrow_Night_Eighties',
      \ 'active': {
      \   'left': [['mode', 'paste'], ['readonly', 'filename', 'modified']],
      \   'right': [['lineinfo'], ['gitbranch']]
      \ },
      \ 'inactive': {
      \   'left': [['filename']],
      \   'right': []
      \ },
      \ 'component_function': {
      \   'gitbranch': 'gitbranch#name'
      \ },
      \ }
