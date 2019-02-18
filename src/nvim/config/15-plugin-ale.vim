Plug 'w0rp/ale'

let g:ale_completion_enabled = 0
let g:ale_fix_on_save = 1
let g:ale_fixers = {}
let g:ale_fixers['*'] = ['remove_trailing_lines', 'trim_whitespace', 'prettier']
let g:ale_fixers.html = ['prettier']
let g:ale_fixers.typescript = ['tslint', 'prettier']
let g:ale_fixers['typescript.tsx'] = g:ale_fixers.typescript
let g:ale_fixers.javascript = ['eslint', 'prettier']
let g:ale_fixers['javascript.jsx'] = g:ale_fixers.javascript
