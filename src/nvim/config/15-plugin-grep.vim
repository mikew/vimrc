Plug 'dyng/ctrlsf.vim'

nmap <C-F>f <Plug>CtrlSFPrompt

if has('nvim')
  autocmd User VimrcGUIEnter nmap <S-D-f> <Plug>CtrlSFPrompt
  autocmd User VimrcGUIEnter nmap <S-D-F> <Plug>CtrlSFPrompt
else
  autocmd User VimrcGUIEnter nmap <D-F> <Plug>CtrlSFPrompt
endif
