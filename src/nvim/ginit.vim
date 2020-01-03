let s:vim_ui = vimrc#determine_ui()

if s:vim_ui == 'term'
  finish
endif

function! s:get_value_or_star(dictionary, key)
  return get(a:dictionary, a:key, get(a:dictionary, '*'))
endfunction

let s:font_map = {
      \ 'nvim-qt': 'Fira Mono',
      \ '*': 'FiraMono-Regular',
      \ }
let s:font_size_map = {
      \ '*': 12,
      \ }
let s:linespace_map = {
      \ 'nvim-qt': 2,
      \ '*': 3,
      \ }

let s:font = s:get_value_or_star(s:font_map, s:vim_ui)
let s:font_size = s:get_value_or_star(s:font_size_map, s:vim_ui)
let s:linespace = s:get_value_or_star(s:linespace_map, s:vim_ui)
