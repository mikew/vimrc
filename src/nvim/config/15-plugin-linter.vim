Plug 'w0rp/ale'

let g:ale_completion_enabled = 0
let g:ale_disable_lsp = 1
let g:ale_fix_on_save = 1

let g:ale_fixers = {}

let g:ale_fixers['*'] = ['remove_trailing_lines', 'trim_whitespace', 'prettier']

let g:ale_fixers['typescript'] = ['eslint', 'tslint', 'prettier']
let g:ale_fixers['typescript.tsx'] = g:ale_fixers['typescript']

let g:ale_fixers['javascript'] = ['eslint', 'prettier']
let g:ale_fixers['javascript.jsx'] = g:ale_fixers['javascript']

let g:ale_linters_explicit = 1
let g:ale_linters = {}

let g:ale_linters['typescript'] = ['eslint', 'tslint']
let g:ale_linters['typescript.tsx'] = g:ale_linters['typescript']

let g:ale_linters['javascript'] = ['eslint']
let g:ale_linters['javascript.tsx'] = g:ale_linters['typescript']

nmap gh <Plug>(ale_hover)
