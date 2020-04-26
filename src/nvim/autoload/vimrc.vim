function! vimrc#has_gui_running()
  if vimrc#determine_ui() == 'term'
    return 0
  endif

  return 1
endfunction

function! vimrc#has_gui_mac()
  return has('mac') && vimrc#has_gui_running()
endfunction

function! vimrc#determine_ui()
  if has('gui_running') && has('gui_macvim')
    return 'macvim'
  endif

  if has('gui_vimr')
    return 'vimr'
  endif

  if exists(':GonvimWorkspaceNew')
    return 'goneovim'
  endif

  if exists('neovim_dot_app')
    return 'neovim_dot_app'
  endif

  " Try to keep nvim-qt last since its function names aren't very specific.
  if exists(':Guifont')
        \ && exists(':GuiLinespace')
        \ && exists(':GuiTabline')
        \ && exists(':GuiPopupmenu')
        \ && exists(':GuiTreeviewToggle')
    return 'nvim-qt'
  endif

  return 'term'
endfunction

let s:os = ''
function! vimrc#os()
  if s:os == ''
    if has('win64') || has('win32') || has('win16')
      let s:os = 'win32'
    else
      let l:uname = substitute(system('uname'), '\n', '', '')

      if l:uname == 'Darwin'
        let s:os = 'mac'
      else
        let s:os = 'unix'
      endif
    endif
  endif

  return s:os
endfunction
