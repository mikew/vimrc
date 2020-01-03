let s:vim_ui = vimrc#determine_ui()

if s:vim_ui == 'term'
  finish
endif

function! s:get_value_or_star(dictionary, key)
  return get(a:dictionary, a:key, get(a:dictionary, '*'))
endfunction

let s:font_map = {
      \ 'nvim-qt': 'Fira Mono',
      \ '*': 'FiraMono-Regular',
      \ }
let s:font_size_map = {
      \ '*': 12,
      \ }
let s:linespace_map = {
      \ 'nvim-qt': 2,
      \ '*': 3,
      \ }

let s:font = s:get_value_or_star(s:font_map, s:vim_ui)
let s:font_size = s:get_value_or_star(s:font_size_map, s:vim_ui)
let s:linespace = s:get_value_or_star(s:linespace_map, s:vim_ui)

if s:vim_ui == 'macvim'
  " macmenu *needs* to be called in gvimrc
  macmenu File.New\ Tab key=<nop>
  macmenu File.Print key=<nop>

  execute 'set linespace=' . s:linespace
  execute 'set guifont=' . s:font . ':h' . s:font_size
endif

if s:vim_ui == 'vimr'
  nmap <S-D-{> gT
  nmap <S-D-}> gt

  imap <S-D-{> <C-o>gT
  imap <S-D-}> <C-o>gt
endif

if s:vim_ui == 'nvim-qt'
  if has('mac')
    " Save.
    nmap <D-S> :w<CR>
    imap <D-S> <C-o>:w<CR>

    " Select All.
    nmap <D-A> ggVG
    imap <D-A> <C-o>ggVG

    " Undo.
    nmap <D-Z> u
    imap <D-Z> <C-o>u

    " Redo.
    nmap <D-S-Z> <C-R>
    imap <D-S-Z> <C-o><C-R>

    " Command+Arrow movement.
    nmap <D-Left> ^
    imap <D-Left> <C-o>I

    nmap <D-Right> $
    imap <D-Right> <C-o>A

    nmap <D-Up> gg
    imap <D-Up> <C-o>gg

    nmap <D-Down> G$
    imap <D-Down> <C-o>G

    " Alt+Arrow movement.
    nmap <M-Left> b
    imap <M-Left> <C-o>b

    nmap <M-Right> w
    imap <M-Right> <C-o>w

    " Tab navigation.
    nmap <S-D-]> gt
    imap <S-D-]> <C-o>gt

    nmap <S-D-[> gT
    imap <S-D-[> <C-o>gT

    " Close Tab.
    nmap <D-W> :tabclose<CR>
    imap <D-W> :tabclose<CR>

    " Close Window.
    nmap <S-D-W> :qa<CR>
    imap <S-D-W> :qa<CR>

    " Close all but current.
    nmap <M-D-W> :tabonly<CR>
    imap <M-D-W> :tabonly<CR>

    " Cut.
    vmap <D-X> "+x

    " Copy.
    vmap <D-C> "+ygv

    " Paste.
    nmap <D-V> "+P
    imap <D-V> <C-o>"+P
  endif

  GuiTabline 0
  GuiPopupmenu 0
  execute 'GuiFont ' . s:font . ':h' . s:font_size
  execute 'GuiLinespace ' . s:linespace
endif

doautocmd User VimrcGUIEnter
