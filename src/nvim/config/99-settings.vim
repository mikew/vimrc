""
"" Basic Setup
""

" Show line numbers
set number

" Show line and column number
" set ruler

" Turn on syntax highlighting allowing local overrides
syntax enable

colorscheme base16-eighties
set termguicolors

""
"" Whitespace
""

" don't wrap lines
set nowrap

" a tab is two spaces
set tabstop=2

" an autoindent (with <<) is two spaces
set shiftwidth=2

" use spaces, not tabs
set expandtab

" Show invisible characters
set list

" backspace through everything in insert mode
set backspace=indent,eol,start

set cursorline
set colorcolumn=80
set mouse=a

" List chars

" Reset the listchars
set listchars=""

" a tab should display as "  ", trailing whitespace as "."
set listchars=tab:\ \  " comment just so whitespace isn't truncated.

" show trailing spaces as dots
set listchars+=trail:.

" The character to show in the last column when wrap is
" off and the line continues beyond the right of the screen
set listchars+=extends:>

" The character to show in the last column when wrap is
" off and the line continues beyond the left of the screen
set listchars+=precedes:<

set guioptions=

""
"" Searching
""

" highlight matches
set hlsearch

" incremental searching
set incsearch

" searches are case insensitive...
set ignorecase

" ... unless they contain at least one capital letter
set smartcase

""
"" Wild settings
""

" TODO: Investigate the precise meaning of these settings
" set wildmode=list:longest,list:full

" Disable output and VCS files
set wildignore+=*.o,*.out,*.obj,.git,*.rbc,*.rbo,*.class,.svn,*.gem

" Disable archive files
set wildignore+=*.zip,*.tar.gz,*.tar.bz2,*.rar,*.tar.xz

" Ignore bundler and sass cache
set wildignore+=*/vendor/gems/*,*/vendor/cache/*,*/.bundle/*,*/.sass-cache/*

" Ignore librarian-chef, vagrant, test-kitchen and Berkshelf cache
set wildignore+=*/tmp/librarian/*,*/.vagrant/*,*/.kitchen/*,*/vendor/cookbooks/*

" Ignore rails temporary asset caches
set wildignore+=*/tmp/cache/assets/*/sprockets/*,*/tmp/cache/assets/*/sass/*

" Disable temp and backup files
set wildignore+=*.swp,*~,._*

""
"" Backup and swap files
""

set undofile
set undodir^=~/.cache/vim
set backupdir=~/.cache/vim
set directory=~/.cache/vim
let g:netrw_home='~/.cache/vim'
if !has('nvim')
  set viminfofile=~/.cache/vim/viminfo
endif

map Q <Nop>
map q: :q
