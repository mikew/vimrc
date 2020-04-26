if &compatible
  set nocompatible
endif

function! s:cd_to_argv()
  let l:start_directory = getcwd()

  if argc() == 1
    let l:start_file = fnamemodify(argv()[0], ':p')

    if isdirectory(l:start_file)
      let l:start_directory = l:start_file
    else
      let l:start_directory = fnamemodify(l:start_file, ':p:h')
    endif
  endif

  " Change vim's pwd to start_directory.
  exec 'cd ' . l:start_directory
endfunction

call s:cd_to_argv()

call plug#begin('~/.cache/vim-plug')
