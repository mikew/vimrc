Plug 'scrooloose/nerdtree'

" Give nerdtree even more room.
autocmd FileType nerdtree setlocal signcolumn=no

let NERDTreeHijackNetrw = 0
let NERDTreeRespectWildIgnore = 1
let NERDTreeMinimalUI = 1
let NERDTreeWinPos = 'right'
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
let NERDTreeCustomOpenArgs = {
      \ 'file': {
      \   'where': 't',
      \   'reuse': 'all',
      \   'keepopen': 1,
      \   'stay': 0,
      \ },
      \ }

function! s:OnDidOpenSplit(...)
  edit NERD_tree_1
  set ft=nerdtree
endfunction

function! s:OnDidOpenDrawer(...)
  let t:NERDTreeBufName = a:1
endfunction

" vim can't access script local vars in mappings
" vim can access script local functions in mappings
" vim is just wonderful
function! s:Toggle(...)
  call call(s:drawer.FocusOrToggle, a:000, s:drawer)
endfunction

nnoremap <silent><leader>n :call <sid>Toggle()<CR>

function! s:autocmd_vimenter()
  " Hack to hide netrw if vim was passed a directory.
  if argc() == 1
    if isdirectory(argv()[0])
      bd
    endif
  endif

  let s:drawer = drawer#Create({
        \ 'Size': 30,
        \ 'BufNamePrefix': 'nerdtree_drawer_',
        \ 'Position': 'right',
        \ 'OnDidOpenSplit': function('s:OnDidOpenSplit'),
        \ 'OnDidOpenDrawer': function('s:OnDidOpenDrawer'),
        \ })

  " Open nerdtree and close it so the buffer exists.
  NERDTree
  NERDTreeClose

  " Open our own mirror.
  call s:drawer.Toggle()

  " Gotta refresh when we do shit all hacky like my life.
  NERDTreeRefresh

  call drawer#GotoPreviousOrFirst()
endfunction

autocmd VimEnter * :call s:autocmd_vimenter()
