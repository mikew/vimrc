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

function! s:OnOpenSplit()
  edit NERD_tree_1
  set ft=nerdtree
endfunction

function! s:OnCreate()
endfunction

function! s:OnOpen()
endfunction

" vim can't access script local vars in mappings
" vim can access script local functions in mappings
" vim is just wonderful
function! s:Toggle(...)
  call s:drawer.Toggle(1)
endfunction

let s:drawer = CreateDrawer({
      \ 'Size': 30,
      \ 'BufNamePrefix': 'NERD_tree_',
      \ 'Position': 'right',
      \ 'OnOpenSplit': function('s:OnOpenSplit'),
      \ 'OnCreate': function('s:OnCreate'),
      \ 'OnOpen': function('s:OnOpen'),
      \ })

nnoremap <silent><leader>n :call <sid>Toggle(1)<CR>

function! s:autocmd_vimenter()
  " Hack to hide netrw if vim was passed a directory.
  if argc() == 1
    if isdirectory(argv()[0])
      bd
    endif
  endif

  " Open nerdtree and close it so the buffer exists.
  NERDTreeToggle
  NERDTreeToggle

  " Open our own mirror.
  call s:drawer.Toggle(1)

  " Gotta refresh when we do shit all hacky like my life.
  NERDTreeRefresh

  call s:drawer.Unfocus()
endfunction

autocmd VimEnter * :call s:autocmd_vimenter()

let g:sidebar = s:drawer
