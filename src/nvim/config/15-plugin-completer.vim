Plug 'neoclide/coc.nvim', {'branch': 'release'}

imap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
imap <expr> <Down>  pumvisible() ? "\<C-n>" : "\<Down>"
imap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
imap <expr> <Up>    pumvisible() ? "\<C-p>" : "\<Up>"

" imap <expr> <cr>    pumvisible() ? "\<C-y>" : "\<Plug>delimitMateCR\<Plug>DiscretionaryEnd"
imap <silent><expr> <cr> pumvisible() ? coc#_select_confirm() : "\<Plug>delimitMateCR\<Plug>DiscretionaryEnd"
" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Highlight the symbol and its references when holding the cursor.
" autocmd CursorHold * silent call CocActionAsync('highlight')

" TODO Move to settings.vim?

" TextEdit might fail if hidden is not set.
set hidden

" Some servers have issues with backup files, see #649
set nobackup
set nowritebackup

" Give more space for displaying messages.
" set cmdheight=2

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
set signcolumn=yes

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

nnoremap <silent> gh :call CocActionAsync('doHover')<cr>
nnoremap <silent> K :call <SID>goto_definition()<CR>

function! s:goto_definition()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'help '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Update signature help on jump placeholder
autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')

" Remap for do codeAction of current line
nmap <leader>ac <Plug>(coc-codeaction)
nmap <C-.> <Plug>(coc-codeaction)
autocmd User VimrcGUIEnter nmap <D-.> <Plug>(coc-codeaction)

" Show all diagnostics
nnoremap <silent> <space>a :<C-u>CocList diagnostics<cr>

" Find symbol of current document
nnoremap <silent> <space>o :<C-u>CocList outline<cr>

autocmd VimLeave * silent !prettier_d_slim stop
autocmd VimLeave * silent !eslint_d stop
autocmd VimLeave * silent !stylelint_d stop
