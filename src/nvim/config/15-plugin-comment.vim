Plug 'tomtom/tcomment_vim'

let g:tcomment#blank_lines = 0

map <C-_> :TComment<cr>
imap <C-_> <C-o>:TComment<cr>i
vmap <C-_> :TComment<cr>gv
map <C-/> :TComment<cr>
imap <C-/> <C-o>:TComment<cr>i
vmap <C-/> :TComment<cr>gv

autocmd User VimrcGUIEnter map <D-/> :TComment<cr>
autocmd User VimrcGUIEnter imap <D-/> <C-o>:TComment<cr>i
autocmd User VimrcGUIEnter vmap <D-/> :TComment<cr>gv
