Plug 'ctrlpvim/ctrlp.vim'

let g:ctrlp_map = ''
let g:ctrlp_user_command = 'ag %s --files-with-matches --nocolor --hidden --ignore .git -g ""'
let g:ctrlp_prompt_mappings = {
      \ 'AcceptSelection("e")': ['<c-t>'],
      \ 'AcceptSelection("t")': ['<cr>', '<2-LeftMouse>'],
      \ }

nmap <C-p> :CtrlP<cr>
imap <C-p> <esc>:CtrlP<cr>

if has('gui_running') && has('mac')
  nmap <D-t> :CtrlP<cr>
  imap <D-t> <esc>:CtrlP<cr>
  nmap <D-p> :CtrlP<cr>
  imap <D-p> <esc>:CtrlP<cr>
endif
