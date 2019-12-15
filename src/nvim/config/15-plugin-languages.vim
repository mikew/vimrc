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
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_no_default_key_mappings = 1
let g:vim_markdown_conceal = 0
let g:vim_markdown_conceal_code_blocks = 0
let g:vim_markdown_frontmatter = 1
let g:vim_markdown_json_frontmatter = 1

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
