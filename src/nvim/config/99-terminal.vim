if !has('nvim')
  finish
endif

" Terminal QOL.
" https://www.reddit.com/r/neovim/comments/8siu5k/disable_line_numbers_and_jump_to_insert_mode_in/e11r39k/
au TermOpen * setlocal
      \ nocursorline
au BufLeave term://* stopinsert

let g:QuickTerminalSize = 20
let g:QuickTerminalBufNamePrefix = 'quick_terminal_'
let g:QuickTerminalPosition = 'bottom'

function! QuickTerminalToggle()
  if QuickTerminalIsOpen()
    call QuickTerminalClose()
  else
    call QuickTerminalOpen()
  endif
endfunction

function! QuickTerminalGetWinNum()
  " Search all windows.
  for w in range(1,winnr('$'))
    if bufname(winbufnr(w)) =~# '^' . g:QuickTerminalBufNamePrefix . '\d\+$'
      return w
    endif
  endfor

  return -1
endfunction

function! QuickTerminalIsOpen()
  return QuickTerminalGetWinNum() != -1
endfunction

function! QuickTerminalFocus()
  call QuickTerminalOpen()
endfunction

function! QuickTerminalOpen()
  if QuickTerminalIsOpen()
    exec QuickTerminalGetWinNum() . 'wincmd w'
    return
  endif

  execute QuickTerminalLook() . 'new'
  call QuickTerminalInitWindow()

  if QuickTerminalDoesExist()
    " TODO needs to support multiple quick_terminal_ buffers
    buffer quick_terminal_1
    startinsert!
  else
    call termopen($SHELL, {"detach": 0})
    startinsert!
    " TODO needs to support multiple quick_terminal_ buffers
    file quick_terminal_1
  endif
endfunction

function! QuickTerminalClose()
  if !QuickTerminalIsOpen()
    return
  endif

  exec QuickTerminalGetWinNum() . 'wincmd w'
  q
endfunction

function! QuickTerminalDoesExist()
  " TODO needs to support multiple quick_terminal_ buffers
  return bufnr('quick_terminal_1') != -1
endfunction

" Adapted from nuake
function! QuickTerminalInitWindow()
  " Buffer-local options
  " setlocal filetype=nuake
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal nobuflisted
  setlocal nomodified

  " Window-local options
  setlocal nolist
  setlocal nowrap
  setlocal winfixwidth
  setlocal winfixheight
  setlocal nospell
  setlocal nonumber
  setlocal norelativenumber
  setlocal nofoldenable
  setlocal foldcolumn=0
  setlocal signcolumn=no
  setlocal listchars=
endfunction

" Adapted from nuake
function! QuickTerminalLook()
  let l:winnr = QuickTerminalGetWinNum()

  if g:QuickTerminalPosition == 'bottom'
    let l:mode = 'botright '
  elseif g:QuickTerminalPosition == 'right'
    let l:mode = l:winnr != -1 ? '' : 'botright vertical '
  elseif g:QuickTerminalPosition == 'top'
    let l:mode = 'topleft '
  elseif g:QuickTerminalPosition == 'left'
    let l:mode = l:winnr != -1 ? '' : 'topleft vertical '
  endif

  return l:mode . g:QuickTerminalSize
endfunction

nnoremap <silent><A-t> :call QuickTerminalToggle()<CR>
inoremap <silent><A-t> <Esc>:call QuickTerminalToggle()<CR>
tnoremap <silent><A-t> <C-\><C-n>:call QuickTerminalToggle()<CR>

