let s:vim_ui = vimrc#determine_ui()

if s:vim_ui == 'term'
  finish
endif
