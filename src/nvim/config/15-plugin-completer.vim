Plug 'neoclide/coc.nvim', {'branch': 'release'}

imap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
imap <expr> <Down>  pumvisible() ? "\<C-n>" : "\<Down>"
imap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
imap <expr> <Up>    pumvisible() ? "\<C-p>" : "\<Up>"

" imap <expr> <cr>    pumvisible() ? "\<C-y>" : "\<Plug>delimitMateCR\<Plug>DiscretionaryEnd"
imap <silent><expr> <cr> pumvisible() ? coc#_select_confirm() : "\<Plug>delimitMateCR\<Plug>DiscretionaryEnd"

inoremap <silent><expr> <c-space> coc#refresh()

" autocmd CursorHold * silent call CocActionAsync('highlight')

" TODO Move to settings.vim?

" if hidden is not set, TextEdit might fail.
set hidden

" Some servers have issues with backup files, see #649
set nobackup
set nowritebackup

" Better display for messages
" set cmdheight=2

" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=300

" don't give |ins-completion-menu| messages.
set shortmess+=c

" always show signcolumns
set signcolumn=yes

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

nnoremap <silent> gh :call CocActionAsync('doHover')<cr>
nnoremap <silent> K :call <SID>goto_definition()<CR>

function! s:goto_definition()
  if (index(['vim', 'help'], &filetype) >= 0)
    execute 'help ' . expand('<cword>')
  else
    call CocActionAsync('doHover')
  endif
endfunction

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Update signature help on jump placeholder
autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')

" Remap for do codeAction of current line
nmap <leader>ac <Plug>(coc-codeaction)
autocmd VimrcGUIEnter nmap <D-.> <Plug>(coc-codeaction)

" Show all diagnostics
nnoremap <silent> <space>a :<C-u>CocList diagnostics<cr>

" Find symbol of current document
nnoremap <silent> <space>o :<C-u>CocList outline<cr>

autocmd VimLeave * silent !prettier_d_slim stop
autocmd VimLeave * silent !eslint_d stop
autocmd VimLeave * silent !stylelint_d stop
