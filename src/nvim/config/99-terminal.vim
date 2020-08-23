function! s:OnWillCreateBuffer(...)
  if has('nvim')
    " call termopen($SHELL, {"detach": 0})
    terminal
  else
    terminal ++curwin ++kill=kill
  endif
endfunction

function! s:OnDidOpenDrawer(...)
  setlocal noswapfile
  setlocal nomodified
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
  setlocal nocursorline
  " startinsert!
endfunction

" vim can't access script local vars in mappings
" vim can access script local functions in mappings
" vim is just wonderful
function! s:Toggle(...)
  call call(s:drawer.FocusOrToggle, a:000, s:drawer)
endfunction
function! s:CreateNew(...)
  call call(s:drawer.CreateNew, a:000, s:drawer)
endfunction
function! s:Go(...)
  call call(s:drawer.Go, a:000, s:drawer)
endfunction

function! s:autocmd_vimenter()
  let s:drawer = drawer#Create({
        \ 'Size': 15,
        \ 'BufNamePrefix': 'quick_terminal_',
        \ 'Position': 'bottom',
        \ 'OnWillCreateBuffer': function('s:OnWillCreateBuffer'),
        \ 'OnDidOpenDrawer': function('s:OnDidOpenDrawer'),
        \ })
endfunction

autocmd VimEnter * :call s:autocmd_vimenter()

if has('nvim')
  au BufLeave term://* stopinsert
  au BufLeave quick_terminal_* stopinsert
endif

nnoremap <silent><leader>tc :call <sid>Toggle()<CR>
tnoremap <silent><leader>tc <C-\><C-n>:call <sid>Toggle()<CR>
nnoremap <silent><leader>tn :call <sid>CreateNew()<CR>
tnoremap <silent><leader>tn <C-\><C-n>:call <sid>CreateNew()<CR>
nnoremap <silent><leader>tt :call <sid>Go(1)<CR>
tnoremap <silent><leader>tt <C-\><C-n>:call <sid>Go(1)<CR>
nnoremap <silent><leader>tT :call <sid>Go(-1)<CR>
tnoremap <silent><leader>tT <C-\><C-n>:call <sid>Go(-1)<CR>

tnoremap <silent><D-v> <C-\><C-n>"+pi
