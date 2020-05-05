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

function! s:OnOpenSplit(...)
  edit NERD_tree_1
  set ft=nerdtree
endfunction

" vim can't access script local vars in mappings
" vim can access script local functions in mappings
" vim is just wonderful
function! s:Toggle(...)
  call call(s:drawer.FocusOrToggle, a:000, s:drawer)
endfunction

let s:drawer = CreateDrawer({
      \ 'Size': 30,
      \ 'BufNamePrefix': 'NERD_tree_',
      \ 'Position': 'right',
      \ 'OnOpenSplit': function('s:OnOpenSplit'),
      \ })

nnoremap <silent><leader>n :call <sid>Toggle()<CR>

function! s:autocmd_vimenter()
  " Hack to hide netrw if vim was passed a directory.
  if argc() == 1
    if isdirectory(argv()[0])
      bd
    endif
  endif

  " Open nerdtree and close it so the buffer exists.
  NERDTree
  NERDTreeClose

  " Open our own mirror.
  call s:drawer.Toggle()

  " Gotta refresh when we do shit all hacky like my life.
  NERDTreeRefresh

  call DrawerGotoPreviousOrFirst()
endfunction

autocmd VimEnter * :call s:autocmd_vimenter()
