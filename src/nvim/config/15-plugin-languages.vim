Plug 'sheerun/vim-polyglot'
let g:polyglot_disabled = [
      \ 'typescript',
      \ 'typescriptreact'
      \ ]

Plug 'ap/vim-css-color'
Plug 'leafgarland/typescript-vim'
" https://github.com/leafgarland/typescript-vim/issues/82
autocmd BufNewFile,BufRead *.ts,*.tsx setlocal filetype=typescript

Plug 'chriskempson/base16-vim'
