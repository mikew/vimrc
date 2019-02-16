let s:path = fnamemodify(resolve(expand('<sfile>:p')), ':h')

for f in split(glob('~/.config/nvim/config/*.vim'), '\n')
  exe 'source' f
endfor

