Plug 'dyng/ctrlsf.vim'

nmap <C-F>f <Plug>CtrlSFPrompt

if (has('gui_running') && has('mac')) || has('gui_vimr')
  if has('nvim')
    nmap <S-D-f> <Plug>CtrlSFPrompt
  else
    nmap <D-F> <Plug>CtrlSFPrompt
  endif
endif
