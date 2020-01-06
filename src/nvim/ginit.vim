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
    nmap <D-s> :w<CR>
    imap <D-s> <C-o>:w<CR>
    xmap <D-s> <Esc>:w<CR>gv

    " Select All.
    nmap <D-a> ggVG
    imap <D-a> <C-o>ggVG

    " Undo.
    nmap <D-z> u
    imap <D-z> <C-o>u

    " Redo.
    nmap <D-Z> <C-R>
    imap <D-Z> <C-o><C-R>

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
    nmap <D-w> :tabclose<CR>
    imap <D-w> :tabclose<CR>

    " Close Window.
    nmap <D-w> :qa<CR>
    imap <D-w> :qa<CR>

    " Close all but current.
    nmap <M-D-w> :tabonly<CR>
    imap <M-D-w> :tabonly<CR>

    " Cut.
    vmap <D-x> "+x

    " Copy.
    vmap <D-c> "+ygv

    " Paste.
    nmap <D-v> "+P
    imap <D-v> <C-o>"+P
  else
    " Save.
    nmap <C-s> :w<CR>
    imap <C-s> <C-o>:w<CR>
    xmap <C-s> <Esc>:w<CR>gv

    " Select All.
    nmap <C-a> ggVG
    imap <C-a> <C-o>ggVG

    " Undo.
    nmap <C-z> u
    imap <C-z> <C-o>u

    " Redo.
    " nmap <C-S-Z> <C-R>
    " imap <C-S-Z> <C-o><C-R>

    " Command+Arrow movement.
    " nmap <D-Left> ^
    " imap <D-Left> <C-o>I

    " nmap <D-Right> $
    " imap <D-Right> <C-o>A

    " nmap <D-Up> gg
    " imap <D-Up> <C-o>gg

    " nmap <D-Down> G$
    " imap <D-Down> <C-o>G

    " Alt+Arrow movement.
    nmap <C-Left> b
    imap <C-Left> <C-o>b

    nmap <C-Right> w
    imap <C-Right> <C-o>w

    " Tab navigation.
    nmap <C-Tab> gt
    imap <C-Tab> <C-o>gt

    nmap <C-S-Tab> gT
    imap <C-S-Tab> <C-o>gT

    " Close Tab.
    " nmap <D-W> :tabclose<CR>
    " imap <D-W> :tabclose<CR>

    " Close Window.
    " nmap <S-D-W> :qa<CR>
    " imap <S-D-W> :qa<CR>

    " Close all but current.
    nmap <M-W> :tabonly<CR>
    imap <M-W> :tabonly<CR>

    " Cut.
    vmap <C-x> "+x

    " Copy.
    vmap <C-c> "+ygv

    " Paste.
    " nmap <C-S-V> "+P
    " imap <C-S-V> <C-o>"+P
  endif

  GuiTabline 0
  GuiPopupmenu 0
  execute 'GuiFont ' . s:font . ':h' . s:font_size
  execute 'GuiLinespace ' . s:linespace
endif

doautocmd User VimrcGUIEnter
