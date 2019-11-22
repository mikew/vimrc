Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-buffer.vim'
Plug 'Shougo/neco-vim'
Plug 'prabirshrestha/asyncomplete-necovim.vim'
Plug 'prabirshrestha/asyncomplete-file.vim'

let g:asyncomplete_smart_completion = 1
let g:asyncomplete_auto_popup = 1
let g:asyncomplete_remove_duplicates = 1

imap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
imap <expr> <Down>  pumvisible() ? "\<C-n>" : "\<Down>"
imap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
imap <expr> <Up>    pumvisible() ? "\<C-p>" : "\<Up>"
imap <expr> <cr>    pumvisible() ? "\<C-y>" : "\<Plug>delimitMateCR\<Plug>DiscretionaryEnd"

imap <c-space> <Plug>(asyncomplete_force_refresh)

au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#ale#get_source_options({
      \ 'priority': 10,
      \ }))

au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#necovim#get_source_options({
      \ 'name': 'necovim',
      \ 'whitelist': ['vim'],
      \ 'completor': function('asyncomplete#sources#necovim#completor'),
      \ }))

au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#file#get_source_options({
      \ 'name': 'file',
      \ 'whitelist': ['*'],
      \ 'priority': 10,
      \ 'completor': function('asyncomplete#sources#file#completor')
      \ }))
