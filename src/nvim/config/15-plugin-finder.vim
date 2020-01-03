Plug '/usr/local/opt/fzf'

let $FZF_DEFAULT_COMMAND="fd --type file --color never --hidden --exclude .git"
let $FZF_DEFAULT_OPTS = '--inline-info'

let g:fzf_action = {
      \ 'enter': 'tab split'
      \ }

nmap <C-p> :FZF<cr>
imap <C-p> <esc>:FZF<cr>

if vimrc#has_gui_mac()
  nmap <D-t> :FZF<cr>
  imap <D-t> <esc>:FZF<cr>
  nmap <D-p> :FZF<cr>
  imap <D-p> <esc>:FZF<cr>
endif
