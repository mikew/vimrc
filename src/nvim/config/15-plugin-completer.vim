"
" Use Ale
"
let g:ale_completion_enabled = 1

"
" vim-lsp
" Provides an omnifunc so it's useful anywhere
"
" Plug 'prabirshrestha/async.vim'
" Plug 'prabirshrestha/vim-lsp'
"
" let g:lsp_async_completion = 1
" " Handled by ale.
" let g:lsp_diagnostics_enabled = 0
"
" if executable('typescript-language-server')
"   au User lsp_setup call lsp#register_server({
"         \ 'name': 'typescript-language-server',
"         \ 'cmd': {server_info->[&shell, &shellcmdflag, 'typescript-language-server --stdio']},
"         \ 'root_uri':{server_info->lsp#utils#path_to_uri(lsp#utils#find_nearest_parent_file_directory(lsp#utils#get_buffer_path(), 'tsconfig.json'))},
"         \ 'whitelist': ['typescript', 'typescript.tsx', 'javascript', 'javascript.jsx'],
"         \ })
"
"   " autocmd FileType typescript setlocal omnifunc=lsp#complete
"   " autocmd FileType typescript.tsx setlocal omnifunc=lsp#complete
"   " autocmd FileType javascript setlocal omnifunc=lsp#complete
"   " autocmd FileType javascript.jsx setlocal omnifunc=lsp#complete
" else
"   echohl ErrorMsg
"   echom 'Sorry, `typescript-language-server` is not installed. See :h vim-lsp-typescript for more details on setup.'
"   echohl NONE
" endif
"
" if executable('pyls')
"   au User lsp_setup call lsp#register_server({
"     \ 'name': 'pyls',
"     \ 'cmd': {server_info->['pyls']},
"     \ 'whitelist': ['python'],
"     \ })
"
"   " autocmd FileType python setlocal omnifunc=lsp#complete
" else
"   echohl ErrorMsg
"   echom 'Sorry, `pyls` is not installed. See :h vim-lsp-python for more details on setup.'
"   echohl NONE
" endif

"
" YouCompleteMe
"
" function! BuildYCM(info)
"   " info is a dictionary with 3 fields
"   " - name:   name of the plugin
"   " - status: 'installed', 'updated', or 'unchanged'
"   " - force:  set on PlugInstall! or PlugUpdate!
"   if a:info.status == 'installed' || a:info.force
"     !./install.py
"   endif
" endfunction
"
" Plug 'Valloric/YouCompleteMe', { 'do': function('BuildYCM') }
" let g:ycm_complete_in_comments = 1
" let g:ycm_collect_identifiers_from_comments_and_strings = 1
" let g:ycm_filetype_specific_completion_to_disable = {}
" let g:ycm_filetype_specific_completion_to_disable['typescript'] = 1
" let g:ycm_filetype_specific_completion_to_disable['typescript.tsx'] = 1
" let g:ycm_filetype_specific_completion_to_disable['javascript'] = 1
" let g:ycm_filetype_specific_completion_to_disable['javascript.jsx'] = 1
" let g:ycm_filetype_specific_completion_to_disable['python'] = 1

"
" VimCompletesMe
"
" Plug 'ajh17/VimCompletesMe'
"
" autocmd FileType vim let b:vcm_tab_complete = 'vim'

"
" asyncomplete
"
Plug 'prabirshrestha/asyncomplete.vim'
" Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'prabirshrestha/asyncomplete-buffer.vim'
Plug 'yami-beta/asyncomplete-omni.vim'
Plug 'Shougo/neco-vim'
Plug 'prabirshrestha/asyncomplete-necovim.vim'

let g:asyncomplete_smart_completion = 1
let g:asyncomplete_auto_popup = 1
let g:asyncomplete_remove_duplicates = 1

inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<cr>"
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
