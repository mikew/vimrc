if has('nvim')
  au TermOpen * setlocal
        \ nocursorline
  au BufLeave term://* stopinsert

  nnoremap <silent><A-t> :call QuickTerminalToggle(1)<CR>
  inoremap <silent><A-t> <Esc>:call QuickTerminalToggle(1)<CR>
  tnoremap <silent><A-t> <C-\><C-n>:call QuickTerminalToggle(1)<CR>
endif

nnoremap <silent><leader>` :call QuickTerminalToggle(1)<CR>
inoremap <silent><leader>` <Esc>:call QuickTerminalToggle(1)<CR>
tnoremap <silent><leader>` <C-\><C-n>:call QuickTerminalToggle(1)<CR>

" TODO
" This is like 99% like a framework for "persistent vim drawers" and
" (hopefully soon) the ability to switch between a bunch of buffers in them
" while remembering the last buffer.
" The only things the actually deal with the terminal is a bit in
" `QuickTerminalOpen` and `QuickTerminalInitWindow`.

let g:QuickTerminalSize = 20
let g:QuickTerminalBufNamePrefix = 'quick_terminal_'
let g:QuickTerminalPosition = 'bottom'

function! QuickTerminalToggle(should_start_terminal)
  if QuickTerminalIsOpen()
    call QuickTerminalClose()
  else
    call QuickTerminalOpen(a:should_start_terminal)
  endif
endfunction

function! QuickTerminalOpen(should_start_terminal)
  if QuickTerminalIsOpen()
    return
  endif

  " Open and configure the split.
  execute QuickTerminalLook() . 'new'
  if a:should_start_terminal
    call QuickTerminalInitWindow()
  endif

  if QuickTerminalDoesExist()
    " TODO needs to support multiple quick_terminal_ buffers
    buffer quick_terminal_1
  else
    if a:should_start_terminal
      " Start the actual shell.
      if has('nvim')
        call termopen($SHELL, {"detach": 0})
      else
        terminal ++curwin ++kill=kill
      endif
    endif

    " TODO needs to support multiple quick_terminal_ buffers
    file quick_terminal_1
  endif

  if a:should_start_terminal
    startinsert!
  endif
endfunction

function! QuickTerminalClose()
  if !QuickTerminalIsOpen()
    return
  endif

  call QuickTerminalFocus()
  call QuickTerminalStoreSize()
  q
endfunction

function! QuickTerminalIsOpen()
  return QuickTerminalGetWinNum() != -1
endfunction

function! QuickTerminalGetWinNum()
  " Search all windows.
  for w in range(1,winnr('$'))
    if QuickTerminalIsBuffer(bufname(winbufnr(w)))
      return w
    endif
  endfor

  return -1
endfunction

function! QuickTerminalDoesExist()
  " TODO needs to support multiple quick_terminal_ buffers
  return bufnr('quick_terminal_1') != -1
endfunction

function! QuickTerminalIsBuffer(name)
  return bufname(a:name) =~# '^' . g:QuickTerminalBufNamePrefix . '\d\+$'
endfunction

function! QuickTerminalFocus()
  if QuickTerminalIsOpen()
    " wincmd w seems to focus the wrong window if this is called from the
    " terminal itself.
    " TODO this may need to actualy determine if called from a terminal, not
    " just a quick_terminal_, if we want better integration with plain ol'
    " terminals.
    if QuickTerminalIsBuffer(bufnr())
      return
    endif

    exec QuickTerminalGetWinNum() . 'wincmd w'
  endif
endfunction

function! QuickTerminalUnfocus()
  if QuickTerminalIsBuffer(bufname())
    wincmd p
  endif
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

  let l:size = g:last_quick_terminal_size != 0 ? g:last_quick_terminal_size : g:QuickTerminalSize
  return l:mode . l:size
endfunction

function! s:autocmd_tableave()
  if QuickTerminalIsOpen()
    let g:was_quick_terminal_open_before_tabchange = 1
    call QuickTerminalFocus()
    call QuickTerminalStoreSize()
    call QuickTerminalUnfocus()
  else
    let g:was_quick_terminal_open_before_tabchange = 0
  endif
endfunction

autocmd TabLeave * call s:autocmd_tableave()

let g:last_quick_terminal_size = 0
function! s:autocmd_tabenter()
  if !g:was_quick_terminal_open_before_tabchange
    return
  endif

  call QuickTerminalOpen(0)
  call QuickTerminalFocus()
  if g:last_quick_terminal_size != 0
    " TODO handle direction
    exec 'resize ' . g:last_quick_terminal_size
  endif
  call QuickTerminalUnfocus()
endfunction

autocmd TabEnter * call s:autocmd_tabenter()

function! QuickTerminalStoreSize()
  let g:last_quick_terminal_size = winheight(0)
endfunction

function! s:autocmd_bufenter()
  if winnr("$") == 1 && QuickTerminalIsBuffer(bufname())
    q
  endif
endfunction

autocmd BufEnter * call s:autocmd_bufenter()

