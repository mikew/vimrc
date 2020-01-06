if !has('nvim')
  finish
endif

" https://www.reddit.com/r/neovim/comments/8siu5k/disable_line_numbers_and_jump_to_insert_mode_in/e0zpvy5/
let s:term_buf = 0
let s:term_win = 0

function! TermToggle(height)
  if win_gotoid(s:term_win)
    hide
  else
    belowright new terminal
    exec "resize " . a:height
    try
      exec "buffer " . s:term_buf
      exec "bd terminal"
    catch
      call termopen($SHELL, {"detach": 0})
      let s:term_buf = bufnr("")
    endtry
    startinsert!
    let s:term_win = win_getid()
  endif
endfunction

nnoremap <silent><A-t> :call TermToggle(12)<CR>
inoremap <silent><A-t> <Esc>:call TermToggle(12)<CR>
tnoremap <silent><A-t> <C-\><C-n>:call TermToggle(12)<CR>

" Terminal QOL.
" https://www.reddit.com/r/neovim/comments/8siu5k/disable_line_numbers_and_jump_to_insert_mode_in/e11r39k/
au TermOpen * setlocal
      \ signcolumn=no
      \ listchars=
      \ nonumber
      \ norelativenumber
      \ nocursorline
" au TermOpen * startinsert!
" au BufEnter,BufWinEnter,WinEnter term://* startinsert
au BufLeave term://* stopinsert
