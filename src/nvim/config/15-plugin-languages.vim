Plug 'HerringtonDarkholme/yats.vim'
Plug 'yuezk/vim-js'
Plug 'maxmellon/vim-jsx-pretty'

Plug 'ap/vim-css-color'

Plug 'neoclide/jsonc.vim'
autocmd BufNewFile,BufRead tsconfig.json setlocal filetype=jsonc
autocmd BufNewFile,BufRead tsconfig.*.json setlocal filetype=jsonc

Plug 'ekalinin/Dockerfile.vim'
Plug 'tpope/vim-git'
Plug 'plasticboy/vim-markdown'
Plug 'digitaltoad/vim-pug'
Plug 'vim-python/python-syntax'

Plug 'vim-ruby/vim-ruby'
let g:ruby_indent_assignment_style = 'variable'
let g:ruby_indent_block_style = 'do'

Plug 'hail2u/vim-css3-syntax'
Plug 'cakebaker/scss-syntax.vim'

Plug 'posva/vim-vue'
let g:vue_pre_processors = 'detect_on_enter'

Plug 'stephpy/vim-yaml'

Plug 'chriskempson/base16-vim'
