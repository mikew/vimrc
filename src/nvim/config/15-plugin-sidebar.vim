Plug 'scrooloose/nerdtree'

" Give nerdtree even more room.
autocmd FileType nerdtree setlocal signcolumn=no

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
  NERDTreeToggle
  call UnfocusNERDTreeWindow()
endfunction

map <leader>n :call <sid>nerdtree_toggle_tabs()<cr>

let s:did_enter_once = 0
function! s:autocmd_vimenter()
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
let g:was_nerdtree_open_before_tabchange = 0

function! s:autocmd_tableave()
  let g:was_nerdtree_open_before_tabchange = g:NERDTree.IsOpen()
  NERDTreeFocus
  let g:last_nerdtree_size = winwidth(0)

  call UnfocusNERDTreeWindow()
endfunction

autocmd TabLeave * call s:autocmd_tableave()

function! s:autocmd_tabenter()
  if g:NERDTree.ExistsForTab()
    NERDTreeFocus
  else
    NERDTreeMirror
  endif

  call s:restore_nerdtree_size()

  if !g:was_nerdtree_open_before_tabchange
    NERDTreeToggle
  endif

  call UnfocusNERDTreeWindow()
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

" Not restricted to s: cause it's used in tabdo
function! UnfocusNERDTreeWindow()
  if bufname() == t:NERDTreeBufName
    wincmd p
  endif
endfunction
