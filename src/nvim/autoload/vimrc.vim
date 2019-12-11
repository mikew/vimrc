function! vimrc#has_gui_mac()
  return (has('gui_running') && has('mac')) || has('gui_vimr')
endfunction
