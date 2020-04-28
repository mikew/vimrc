" :function Mylen() dict
" :   return len(self.data)
" :endfunction
" :let mydict = {'data': [0, 1, 2, 3], 'len': function("Mylen")}
" :echo mydict.len()

let s:instances = []

function! CreateDrawer(opts)
  call s:log('createdrawer' . a:opts.BufNamePrefix)
  let a:opts.last_size = 0
  let a:opts.was_open_before_tabchange = 0

  let l:instance = {
        \ 'opts': a:opts,
        \ }

  function! l:instance.Toggle(should_start_terminal) dict
    call s:log('l:instance.Toggle')
    if self.IsOpen()
      call self.Close()
    else
      call self.Open(a:should_start_terminal)
    endif
  endfunction

  function! l:instance.Open(should_start_terminal) dict
    call s:log('l:instance.Open')
    if self.IsOpen()
      return
    endif

    " Open and configure the split.
    execute self.Look() . 'new'
    if a:should_start_terminal
      setlocal bufhidden=hide
      " setlocal nobuflisted
      call self.opts.OnOpenSplit()
    endif

    call self.RestoreSize()

    if self.DoesExist()
      " TODO needs to support multiple buffers
      exec 'buffer ' . self.opts.BufNamePrefix . '1'
    else
      if a:should_start_terminal
        call self.opts.OnCreate()
      endif

      " TODO needs to support multiple buffers
      exec 'file ' . self.opts.BufNamePrefix . '1'
    endif

    if a:should_start_terminal
      call self.opts.OnOpen()
    endif
  endfunction

  function! l:instance.Close() dict
    call s:log('l:instance.Close')
    if !self.IsOpen()
      return
    endif

    call self.Focus()
    call self.StoreSize()
    q
  endfunction

  function! l:instance.IsOpen() dict
    call s:log('l:instance.IsOpen')
    return self.GetWinNum() != -1
  endfunction

  function! l:instance.GetWinNum() dict
    call s:log('l:instance.GetWinNum')
    " Search all windows.
    for w in range(1,winnr('$'))
      if self.IsBuffer(bufname(winbufnr(w)))
        return w
      endif
    endfor

    return -1
  endfunction

  function! l:instance.DoesExist() dict
    call s:log('l:instance.DoesExist')
    " TODO needs to support multiple buffers
    return bufnr(self.opts.BufNamePrefix . '1') != -1
  endfunction

  function! l:instance.IsBuffer(name) dict
    call s:log('l:instance.IsBuffer')
    return bufname(a:name) =~# '^' . self.opts.BufNamePrefix . '\d\+$'
  endfunction

  function! l:instance.Focus() dict
    call s:log('l:instance.Focus')
    if self.IsOpen()
      " wincmd w seems to focus the wrong window if this is called from the
      " terminal itself.
      " TODO this may need to actualy determine if called from a terminal, not
      " just a quick_terminal_, if we want better integration with plain ol'
      " terminals.
      if self.IsBuffer(bufnr())
        return
      endif

      exec self.GetWinNum() . 'wincmd w'
    endif
  endfunction

  function! l:instance.Unfocus() dict
    call s:log('l:instance.Unfocus')
    if self.IsBuffer(bufname())
      wincmd p
    endif
  endfunction

  " Adapted from nuake
  function! l:instance.Look() dict
    call s:log('l:instance.Look')
    let l:winnr = self.GetWinNum()

    if self.opts.Position == 'bottom'
      let l:mode = 'botright '
    elseif self.opts.Position == 'right'
      let l:mode = l:winnr != -1 ? '' : 'botright vertical '
      let l:mode = 'botright vertical'
    elseif self.opts.Position == 'top'
      let l:mode = 'topleft '
    elseif self.opts.Position == 'left'
      let l:mode = l:winnr != -1 ? '' : 'topleft vertical '
      let l:mode = 'topleft vertical'
    endif

    let l:size = self.opts.last_size != 0
          \ ? self.opts.last_size
          \ : self.opts.Size
    return l:mode . l:size
  endfunction

  function! l:instance.StoreSize() dict
    call s:log('l:instance.StoreSize')
    let l:size = winheight(0)

    if self.opts.Position == 'left' || self.opts.Position == 'right'
      let l:size = winwidth(0)
    endif

    let self.opts.last_size = l:size
  endfunction

  function! l:instance.RestoreSize() dict
    call s:log('l:instance.RestoreSize')
    let l:size = self.opts.last_size != 0
          \ ? self.opts.last_size
          \ : self.opts.Size

    let l:command = 'resize'
    if self.opts.Position == 'left' || self.opts.Position == 'right'
      let l:command = 'vertical resize'
    endif
    " TODO handle bottom / side
    exec l:command . ' ' . l:size
  endfunction

  call add(s:instances, l:instance)

  return l:instance
endfunction

function! s:autocmd_tableave()
  let l:winnr = winnr()

  for instance in s:instances
    if instance.IsOpen()
      let instance.opts.was_open_before_tabchange = 1
      call instance.Focus()
      call instance.StoreSize()
      " call instance.Unfocus()
    else
      let instance.opts.was_open_before_tabchange = 0
    endif
  endfor

  exec l:winnr . 'wincmd w'
endfunction

autocmd TabLeave * call s:autocmd_tableave()

function! s:autocmd_tabenter()
  let l:winnr = winnr()

  for instance in s:instances
    if !instance.opts.was_open_before_tabchange
      continue
    endif

    call instance.Open(0)
    call instance.Focus()
    call instance.RestoreSize()
  endfor

  exec l:winnr . 'wincmd w'
endfunction

autocmd TabEnter * call s:autocmd_tabenter()

function! s:autocmd_bufenter()
  let l:total_open = 0
  for instance in s:instances
    if instance.IsOpen()
      let l:total_open = l:total_open + 1
    endif
  endfor

  if winnr("$") == l:total_open
    qa
  endif
endfunction

autocmd BufEnter * call s:autocmd_bufenter()

function! s:OnOpenSplit()
  " Buffer-local options
  " setlocal filetype=nuake
  " setlocal bufhidden=hide
  " setlocal nobuflisted
  setlocal noswapfile
  setlocal nomodified

  " Window-local options
  setlocal winfixwidth
  setlocal winfixheight

  setlocal nolist
  setlocal nowrap
  setlocal nospell
  setlocal nonumber
  setlocal norelativenumber
  setlocal nofoldenable
  setlocal foldcolumn=0
  setlocal signcolumn=no
  setlocal listchars=
  setlocal colorcolumn=
endfunction

function! s:OnCreate()
  " if has('nvim')
  "   call termopen($SHELL, {"detach": 0})
  " else
  "   terminal ++curwin ++kill=kill
  " endif
endfunction

function! s:OnOpen()
  " startinsert!
endfunction

function! s:log(msg)
  " call s:append_to_file(expand('~/vimbs.log'), [a:msg])
  " echom a:msg
endfunction

function! s:append_to_file(file, lines)
  call writefile(readfile(a:file) + a:lines, a:file, "a")
endfunction

" TODO
" vim kinda sucks at some stuff. the order these splits are open is important.
" so we could add an `Order` prop.
" Thing is, that would only be taken into account when drawers are recreated
" on tab switching. Otherwise the user is in total control of the order
" drawers open.
" Maybe there's a way to force them to open?

let t1 = CreateDrawer({
      \ 'Size': 5,
      \ 'BufNamePrefix': 'qt1_',
      \ 'Position': 'top',
      \ 'OnOpenSplit': function('s:OnOpenSplit'),
      \ 'OnCreate': function('s:OnCreate'),
      \ 'OnOpen': function('s:OnOpen'),
      \ })
nnoremap <silent><leader>1 :call t1.Toggle(1)<CR>

let t2 = CreateDrawer({
      \ 'Size': 10,
      \ 'BufNamePrefix': 'qt2_',
      \ 'Position': 'right',
      \ 'OnOpenSplit': function('s:OnOpenSplit'),
      \ 'OnCreate': function('s:OnCreate'),
      \ 'OnOpen': function('s:OnOpen'),
      \ })
nnoremap <silent><leader>2 :call t2.Toggle(1)<CR>

let t3 = CreateDrawer({
      \ 'Size': 15,
      \ 'BufNamePrefix': 'qt3_',
      \ 'Position': 'bottom',
      \ 'OnOpenSplit': function('s:OnOpenSplit'),
      \ 'OnCreate': function('s:OnCreate'),
      \ 'OnOpen': function('s:OnOpen'),
      \ })
nnoremap <silent><leader>3 :call t3.Toggle(1)<CR>

let t4 = CreateDrawer({
      \ 'Size': 20,
      \ 'BufNamePrefix': 'qt4_',
      \ 'Position': 'left',
      \ 'OnOpenSplit': function('s:OnOpenSplit'),
      \ 'OnCreate': function('s:OnCreate'),
      \ 'OnOpen': function('s:OnOpen'),
      \ })
nnoremap <silent><leader>4 :call t4.Toggle(1)<CR>
