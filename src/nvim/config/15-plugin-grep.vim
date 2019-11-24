Plug 'yegappan/grep'

" Only wrapped in execute cause we want the space at the end of the line.
execute 'nnoremap <C-F> :Ag '

if has('gui_running') && has('mac')
  execute 'nnoremap <D-F> :Ag '
endif
