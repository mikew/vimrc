Plug 'ctrlpvim/ctrlp.vim'

let g:ctrlp_user_command = 'ag %s --files-with-matches --nocolor --hidden --ignore .git -g ""'
let g:ctrlp_prompt_mappings = {
      \ 'AcceptSelection("e")': ['<c-t>'],
      \ 'AcceptSelection("t")': ['<cr>', '<2-LeftMouse>'],
      \ }