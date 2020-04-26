Plug 'itchyny/lightline.vim'
Plug 'itchyny/vim-gitbranch'
set laststatus=2
let g:lightline = {
      \ 'enable': {
      \   'statusline': 1,
      \   'tabline': 1,
      \ },
      \ 'colorscheme': 'Tomorrow_Night_Eighties',
      \ 'active': {
      \   'left': [['mode', 'paste'], ['readonly', 'filename', 'modified']],
      \   'right': [['lineinfo'], ['gitbranch']]
      \ },
      \ 'inactive': {
      \   'left': [['filename']],
      \   'right': []
      \ },
      \ 'tabline': {
      \   'left': [['tabs']],
      \   'right': [[]],
      \ },
      \ 'tabline_separator': { 'left': "", 'right': "" },
      \ 'tabline_subseparator': { 'left': "", 'right': "" },
      \ 'tab': {
      \   'active': ['close', 'modified', 'filename'],
      \   'inactive': ['close', 'modified', 'filename'],
      \ },
      \ 'component_function': {
      \   'gitbranch': 'gitbranch#name'
      \ },
      \ }
