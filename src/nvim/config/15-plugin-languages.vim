Plug 'sheerun/vim-polyglot'
let g:polyglot_disabled = [
      \ 'typescript',
      \ 'typescriptreact'
      \ ]

Plug 'ap/vim-css-color'

Plug 'leafgarland/typescript-vim'
" https://github.com/leafgarland/typescript-vim/issues/82
autocmd BufNewFile,BufRead *.ts setlocal filetype=typescript
autocmd BufNewFile,BufRead *.tsx setlocal filetype=typescript.jsx
autocmd BufNewFile,BufRead *.js,*.jsx setlocal filetype=javascript.jsx

Plug 'chriskempson/base16-vim'
