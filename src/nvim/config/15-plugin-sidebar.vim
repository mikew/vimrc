Plug 'scrooloose/nerdtree'

let g:NERDTreeHijackNetrw = 0
let g:NERDTreeRespectWildIgnore = 1
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

" map <leader>n :NERDTreeToggle<CR>
map <leader>n :call <sid>wut()<cr>

function! s:wut()
  if g:NERDTree.IsOpen()
    NERDTreeClose
  else
    NERDTree
    NERDTreeMirror
  endif
endfunction

" Open nerdtree when not passed a file
autocmd stdinreadpre * let s:std_in=1
autocmd vimenter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
" Hide netrw when editing a directory
autocmd vimenter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif

" Mirror nerdtree when entering buffer
" bufwinenter is important:
" https://stackoverflow.com/a/2762067
autocmd bufwinenter * if (!exists("t:NERDTreeBufName") ) | NERDTreeMirror | endif

" Close nerdtree if it's the only thing open
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
