Plug 'scrooloose/nerdtree'

let g:NERDTreeHijackNetrw = 0
let g:NERDTreeRespectWildIgnore = 1
let NERDTreeMinimalUI = 1
let g:NERDTreeWinPos = 'right'
let NERDTreeIgnore=[
      \ '\.pyc$',
      \ '\.pyo$',
      \ '\.rbc$',
      \ '\.rbo$',
      \ '\.class$',
      \ '\.o$',
      \ '\~$',
      \ '\.git$'
      \ ]

function! s:nerdtree_toggle_tabs()
  TabDo NERDTreeToggle
  call UnfocusNERDTreeWindow()
endfunction

map <leader>n :call <sid>nerdtree_toggle_tabs()<cr>

let s:did_enter_once = 0
function! s:autocmd_vimenter()
  echom 'autocmd_vimenter'
  if s:did_enter_once
    return
  endif

  " Hack to hide netrw if vim was passed a directory.
  if argc() == 1
    if isdirectory(argv()[0])
      bd
    endif
  endif

  " Open nerdtree but select previous split.
  NERDTree
  call UnfocusNERDTreeWindow()

  let s:did_enter_once = 1
endfunction

autocmd VimEnter * call s:autocmd_vimenter()

let g:last_nerdtree_size = 0

function! s:autocmd_tableave()
  echom 'autocmd_tableave'

  let l:is_nerdtree_open = g:NERDTree.IsOpen()
  NERDTreeFocus
  let g:last_nerdtree_size = winwidth(0)

  " We needed to ensure nerdtree was open to get the width, so in case we did
  " open in just now, close it again.
  if !l:is_nerdtree_open
    NERDTreeToggle
  endif

  call UnfocusNERDTreeWindow()
endfunction

autocmd TabLeave * call s:autocmd_tableave()

function! s:autocmd_tabenter()
  " TODO This loops through all tabs, which in turn calls more enter/leave
  " events. Might be a way to just keep track of the fact that nerdtree was
  " open?
  let l:is_nerdtree_open = s:is_nerdtree_open()

  if !exists('t:NERDTreeBufName')
    NERDTreeMirror
    call s:restore_nerdtree_size()

    if !l:is_nerdtree_open
      NERDTreeToggle
    endif

    call UnfocusNERDTreeWindow()
  else
    call s:restore_nerdtree_size()
    if !l:is_nerdtree_open
      NERDTreeToggle
    endif
    call UnfocusNERDTreeWindow()
  endif
endfunction

function! s:restore_nerdtree_size()
  NERDTreeFocus
  if g:last_nerdtree_size != 0
    exec 'vertical resize ' . g:last_nerdtree_size
  endif
endfunction

autocmd TabEnter * call s:autocmd_tabenter()

function! s:autocmd_bufenter()
  if winnr("$") == 1 && g:NERDTree.IsOpen()
    q
  endif
endfunction

autocmd BufEnter * call s:autocmd_bufenter()

function! s:is_nerdtree_open()
  let g:is_nerdtree_open = 0

  TabDo if g:NERDTree.IsOpen() | let g:is_nerdtree_open = 1 | endif

  return g:is_nerdtree_open
endfunction

" Not restricted to s: cause it's used in tabdo
function! UnfocusNERDTreeWindow()
  if bufname() == t:NERDTreeBufName
    wincmd p
  endif
endfunction
