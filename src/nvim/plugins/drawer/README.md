# vim-drawer

vim splits that stay open and remember their size between tabs. What you end up
with is something like a framework for NERDTreeTabs, or nuake style terminals.

Supports "tabs".

## Usage

```vim
let s:drawer_options = {}
" Can be top / bottom / left / right.
let s:drawer_options.Position = 'bottom'
" Splits will be named `quick_terminal_{counter}`.
let s:drawer_options.BufNamePrefix = 'quick_terminal_'
" Width / height of the split.
let s:drawer_options.Size = 15

" Callbacks.
" This is how you actually hook into / get the most out of drawers.

" Called after a split was opened, but before any buffer is created / opened.
let s:drawer_options.OnDidOpenSplit = function('s:OnDidOpenSplit')

" Called before a buffer is created for the first time (ie not when toggling).
let s:drawer_options.OnWillCreateBuffer = function('s:OnWillCreateBuffer')

" Called at the end of the opening phase.
let s:drawer_options.OnDidOpenDrawer = function('s:OnDidOpenDrawer')

" Create the drawer instance.
let s:drawer = drawer#Create(s:drawer_options)

" Open / close the drawer.
call s:drawer.Toggle()

" Focus or Open / close the drawer.
call s:drawer.FocusOrToggle()

" Create a new buffer.
call s:drawer.CreateNew()

" Go to the next buffer.
call s:drawer.Go(1)

" Go to the previous buffer.
call s:drawer.Go(-1)

" Go to buffer `counter`.
call s:drawer.GoTo(1)
call s:drawer.GoTo(2)
```

## Examples

I find this the most useful for NERDTree and a terminal, so here's what I do
for those:

### Terminal

```vim
function! s:OnWillCreateBuffer(...)
  if has('nvim')
    call termopen($SHELL, {"detach": 0})
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

function! s:Toggle(...)
  call call(s:drawer.FocusOrToggle, a:000, s:drawer)
endfunction
function! s:CreateNew(...)
  call call(s:drawer.CreateNew, a:000, s:drawer)
endfunction
function! s:Go(...)
  call call(s:drawer.Go, a:000, s:drawer)
endfunction

" Toggle terminal.
nnoremap <silent><leader>tc :call <sid>Toggle()<CR>
tnoremap <silent><leader>tc <C-\><C-n>:call <sid>Toggle()<CR>

" Create new tab.
nnoremap <silent><leader>tn :call <sid>CreateNew()<CR>
tnoremap <silent><leader>tn <C-\><C-n>:call <sid>CreateNew()<CR>

" Go to next tab.
nnoremap <silent><leader>tt :call <sid>Go(1)<CR>
tnoremap <silent><leader>tt <C-\><C-n>:call <sid>Go(1)<CR>

" Go to previous tab.
nnoremap <silent><leader>tT :call <sid>Go(-1)<CR>
tnoremap <silent><leader>tT <C-\><C-n>:call <sid>Go(-1)<CR>
```

### NERDTree / NERDTreeTabs

```vim
function! s:OnDidOpenSplit(...)
  " Normally vim-drawer deals with opening buffers, but here we are relying on
  " the fact that:
  " - NERDTree is called before any of the drawers are opened.
  " - This callback is called before vim-drawer opens the buffer it should.
  edit NERD_tree_1
  set ft=nerdtree

  " This is used internally in NERDTree.
  let t:NERDTreeBufName = 'NERD_tree_1'
endfunction

function! s:autocmd_vimenter()
  " Create a drawer for NERDTree.
  " Note we are kind of abusing the fact that NERDTree and vim-drawer have the
  " same naming scheme.
  let s:drawer = drawer#Create({
        \ 'Size': 30,
        \ 'BufNamePrefix': 'NERD_tree_',
        \ 'Position': 'right',
        \ 'OnDidOpenSplit': function('s:OnDidOpenSplit'),
        \ })

  " Open nerdtree and close it so the buffer exists.
  NERDTree
  NERDTreeClose

  " Open our own mirror.
  call s:drawer.Toggle()

  " We are doing some funky stuff with NERDTree, a call to refresh is needed.
  NERDTreeRefresh

  " Focus non-drawer split.
  call drawer#GotoPreviousOrFirst()
endfunction

autocmd VimEnter * :call s:autocmd_vimenter()

function! s:Toggle(...)
  call call(s:drawer.FocusOrToggle, a:000, s:drawer)
endfunction
nnoremap <silent><leader>n :call <sid>Toggle()<CR>
```
