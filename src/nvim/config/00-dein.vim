if &compatible
  set nocompatible
endif
" Add the dein installation directory into runtimepath
set runtimepath+=~/.cache/dein/repos/github.com/Shougo/dein.vim

let g:ale_completion_enabled = 1
let g:ale_fix_on_save = 1
let g:ale_fixers = {}
let g:ale_fixers['*'] = ['remove_trailing_lines', 'trim_whitespace', 'prettier']
let g:ale_fixers.html = ['prettier']
let g:ale_fixers.typescript = ['tslint', 'prettier']
let g:ale_fixers.javascript = ['eslint', 'prettier']
let g:ale_fixers['javascript.jsx'] = ['eslint', 'prettier']

let g:ale_completion_enabled = 0
let g:deoplete#enable_at_startup = 1


if dein#load_state('~/.cache/dein')
  call dein#begin('~/.cache/dein')

  call dein#add('~/.cache/dein/repos/github.com/Shougo/dein.vim')

  call dein#add('tpope/vim-surround')
  call dein#add('airblade/vim-gitgutter')
  call dein#add('tpope/vim-eunuch')
  call dein#add('terryma/vim-multiple-cursors')
  call dein#add('Raimondi/delimitMate')
  call dein#add('tomtom/tcomment_vim')
  call dein#add('michaeljsmith/vim-indent-object')
  call dein#add('nathanaelkane/vim-indent-guides')
  call dein#add('ntpeters/vim-better-whitespace')
  call dein#add('tpope/vim-repeat')

  call dein#add('chrisbra/NrrwRgn')
  call dein#add('vim-scripts/ZoomWin')

  call dein#add('scrooloose/nerdtree')
  call dein#add('Xuyuanp/nerdtree-git-plugin')

  call dein#add('w0rp/ale')
  call dein#add('Shougo/deoplete.nvim')
  " if !has('nvim')
     call dein#add('roxma/nvim-yarp')
     call dein#add('roxma/vim-hug-neovim-rpc')
  " endif
  call dein#add('mhartington/nvim-typescript', {'build': './install.sh'})

  " call dein#add('sheerun/vim-polyglot')
  call dein#add('chriskempson/base16-vim')
  call dein#add('ap/vim-css-color')
  call dein#add('HerringtonDarkholme/yats.vim')

  call dein#end()
  call dein#save_state()
endif

filetype plugin indent on
syntax enable
