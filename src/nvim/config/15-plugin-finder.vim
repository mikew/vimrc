function! s:find_fzf_directory()
  let l:directories = [
        \ '/usr/local/opt/fzf',
        \ '/usr/local/fzf',
        \ '/home/linuxbrew/.linuxbrew/opt/fzf',
        \ ]

  for d in l:directories
    if isdirectory(d)
      return d
    endif
  endfor

  return 0
endfunction

let s:fzf_directory = s:find_fzf_directory()

if empty(s:fzf_directory)
  finish
endif

execute "Plug '" . s:fzf_directory . "'"

let $FZF_DEFAULT_COMMAND="fd --type file --color never --hidden --exclude .git"
let $FZF_DEFAULT_OPTS = '--inline-info'

let g:fzf_action = {
      \ 'enter': 'tab split'
      \ }

nmap <C-P> :FZF<cr>
imap <C-P> <C-o>:FZF<cr>

autocmd User VimrcGUIEnter nmap <D-T> :FZF<cr>
autocmd User VimrcGUIEnter imap <D-T> <C-o>:FZF<cr>
autocmd User VimrcGUIEnter nmap <D-P> :FZF<cr>
autocmd User VimrcGUIEnter imap <D-P> <C-o>:FZF<cr>
