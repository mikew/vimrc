Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'

Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'prabirshrestha/asyncomplete-buffer.vim'
Plug 'yami-beta/asyncomplete-omni.vim'
Plug 'Shougo/neco-vim'
Plug 'prabirshrestha/asyncomplete-necovim.vim'

let g:asyncomplete_smart_completion = 1
let g:asyncomplete_auto_popup = 1
let g:asyncomplete_remove_duplicates = 1

" Handled by ale.
let g:lsp_diagnostics_enabled = 0

let g:lsp_log_verbose = 1
let g:lsp_log_file = expand('~/vim-lsp.log')

" for asyncomplete.vim log
let g:asyncomplete_log_file = expand('~/asyncomplete.log')

inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<cr>"
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
" set completeopt=longest,menuone
" set omnifunc=syntaxcomplete#Complete
imap <c-space> <Plug>(asyncomplete_force_refresh)

let s:langs_with_completions = [
      \'vim',
      \'javascript',
      \'javascript.jsx',
      \'typescript',
      \'typescript.tsx',
      \'python',
      \]

au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options({
      \ 'name': 'buffer',
      \ 'priority': 10,
      \ 'whitelist': ['*'],
      \ 'blacklist': s:langs_with_completions,
      \ 'completor': function('asyncomplete#sources#buffer#completor'),
      \ }))

au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#omni#get_source_options({
      \ 'name': 'omni',
      \ 'priority': 5,
      \ 'whitelist': ['*'],
      \ 'blacklist': ['c', 'cpp', 'html'] + s:langs_with_completions,
      \ 'completor': function('asyncomplete#sources#omni#completor')
      \  }))

au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#necovim#get_source_options({
      \ 'name': 'necovim',
      \ 'whitelist': ['vim'],
      \ 'completor': function('asyncomplete#sources#necovim#completor'),
      \ }))

if executable('typescript-language-server')
  au User lsp_setup call lsp#register_server({
        \ 'name': 'typescript-language-server',
        \ 'cmd': {server_info->[&shell, &shellcmdflag, 'typescript-language-server --stdio']},
        \ 'root_uri':{server_info->lsp#utils#path_to_uri(lsp#utils#find_nearest_parent_file_directory(lsp#utils#get_buffer_path(), 'tsconfig.json'))},
        \ 'whitelist': ['typescript', 'typescript.tsx', 'javascript', 'javascript.jsx'],
        \ })
else
  echohl ErrorMsg
  echom 'Sorry, `typescript-language-server` is not installed. See :h vim-lsp-typescript for more details on setup.'
  echohl NONE
endif

if executable('pyls')
  au User lsp_setup call lsp#register_server({
    \ 'name': 'pyls',
    \ 'cmd': {server_info->['pyls']},
    \ 'whitelist': ['python'],
    \ })
else
  echohl ErrorMsg
  echom 'Sorry, `pyls` is not installed. See :h vim-lsp-python for more details on setup.'
  echohl NONE
endif
