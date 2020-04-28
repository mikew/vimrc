function! s:OnOpenSplit()
  " Buffer-local options
  setlocal noswapfile
  setlocal nomodified

  " Window-local options
  setlocal winfixwidth
  setlocal winfixheight

  setlocal nolist
  setlocal nowrap
  setlocal nospell
  setlocal nonumber
  setlocal norelativenumber
  setlocal nofoldenable
  setlocal foldcolumn=0
  setlocal signcolumn=no
  setlocal listchars=
  setlocal colorcolumn=
endfunction

function! s:OnCreate()
  if has('nvim')
    call termopen($SHELL, {"detach": 0})
  else
    terminal ++curwin ++kill=kill
  endif
endfunction

function! s:OnOpen()
  startinsert!
endfunction

" vim can't access script local vars in mappings
" vim can access script local functions in mappings
" vim is just wonderful
function! s:Toggle(...)
  call s:drawer.Toggle(1)
endfunction

let s:drawer = CreateDrawer({
      \ 'Size': 20,
      \ 'BufNamePrefix': 'quick_terminal_',
      \ 'Position': 'bottom',
      \ 'OnOpenSplit': function('s:OnOpenSplit'),
      \ 'OnCreate': function('s:OnCreate'),
      \ 'OnOpen': function('s:OnOpen'),
      \ })

if has('nvim')
  au TermOpen * setlocal
        \ nocursorline
  au BufLeave term://* stopinsert

  nnoremap <silent><A-t> :call <sid>Toggle(1)<CR>
  inoremap <silent><A-t> <Esc>:call <sid>Toggle(1)<CR>
  tnoremap <silent><A-t> <C-\><C-n>:call <sid>Toggle(1)<CR>
endif

nnoremap <silent><leader>` :call <sid>Toggle(1)<CR>
inoremap <silent><leader>` <Esc>:call <sid>Toggle(1)<CR>
tnoremap <silent><leader>` <C-\><C-n>:call <sid>Toggle(1)<CR>

