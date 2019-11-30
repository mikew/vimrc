Plug 'tomtom/tcomment_vim'

let g:tcomment#blank_lines = 0

map <C-_> :TComment<cr>
imap <C-_> <Esc>:TComment<cr>i
vmap <C-_> :TComment<cr>gv

if has('gui_running') && has('mac')
  map <D-/> :TComment<cr>
  imap <D-/> <Esc>:TComment<cr>i
  vmap <D-/> :TComment<cr>gv
endif
