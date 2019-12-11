Plug 'dyng/ctrlsf.vim'

nmap <C-F>f <Plug>CtrlSFPrompt

if vimrc#has_gui_mac()
  if has('nvim')
    nmap <S-D-f> <Plug>CtrlSFPrompt
  else
    nmap <D-F> <Plug>CtrlSFPrompt
  endif
endif
