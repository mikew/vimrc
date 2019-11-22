Plug 'tpope/vim-endwise'
let g:endwise_no_mappings = 1
" Regular <cr> is handled in completer
imap <C-X><CR> <CR><Plug>AlwaysEnd

Plug 'Raimondi/delimitMate'
"let delimitMate_expand_cr = 1
let delimitMate_balance_matchpairs = 1
let delimitMate_excluded_regions = ""
let delimitMate_jump_expansion = 1
