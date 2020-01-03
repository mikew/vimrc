Plug '/usr/local/opt/fzf'

let $FZF_DEFAULT_COMMAND="fd --type file --color never --hidden --exclude .git"
let $FZF_DEFAULT_OPTS = ' --inline-info'

let g:fzf_action = {
      \ 'enter': 'tab split'
      \ }

nmap <C-P> :FZF<cr>
imap <C-P> <C-o>:FZF<cr>

autocmd User VimrcGUIEnter nmap <D-T> :FZF<cr>
autocmd User VimrcGUIEnter imap <D-T> <C-o>:FZF<cr>
autocmd User VimrcGUIEnter nmap <D-P> :FZF<cr>
autocmd User VimrcGUIEnter imap <D-P> <C-o>:FZF<cr>
