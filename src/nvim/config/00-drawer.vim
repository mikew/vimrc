let s:instances = []

function! CreateDrawer(opts)
  let a:opts.last_size = 0
  let a:opts.was_open_before_tabchange = 0
  let a:opts.buffers = []
  let a:opts.index = 0

  let l:instance = {
        \ 'opts': a:opts,
        \ }

  function! l:instance.Toggle() dict
    if self.IsOpen()
      call self.Close()
    else
      call self.Open(1)
    endif
  endfunction

  function! l:instance.FocusOrToggle() dict
    if self.IsOpen()
      if self.IsFocused()
        call self.Close()
      else
        call self.Focus()
        call self.opts.OnOpen()
      endif
    else
      call self.Open(1)
    endif
  endfunction

  function! l:instance.Open(should_start_terminal) dict
    if self.IsOpen()
      return
    endif

    " Open and configure the split.
    " execute self.Look() . 'new'
    execute self.Look() . ' split enew'
    setlocal bufhidden=hide
    setlocal nobuflisted
    " setlocal winfixwidth
    " setlocal winfixheight
    " setlocal noequalalways

    " call self.RestoreSize()

    if a:should_start_terminal
      call self.opts.OnOpenSplit()
    endif

    if self.DoesExist()
      " TODO needs to support multiple buffers
      exec 'buffer ' . self.opts.BufNamePrefix . string(self.opts.index + 1)
    else
      if a:should_start_terminal
        call self.opts.OnCreate()
      endif

      " TODO needs to support multiple buffers
      exec 'file ' . self.opts.BufNamePrefix . string(len(self.opts.buffers) + 1)
      call self.RegisterBuffer()
      let self.opts.index = len(self.opts.buffers) - 1
    endif

    if a:should_start_terminal
      call self.opts.OnOpen()
    endif
  endfunction

  function! l:instance.RegisterBuffer() dict
    let l:bufname = bufname()
    if index(self.opts.buffers, l:bufname) == -1
      call add(self.opts.buffers, l:bufname)
    endif
  endfunction

  function l:instance.CreateNew() dict
    if self.IsOpen()
      call self.Focus()
      enew
    else
      execute self.Look() . ' split enew'
      setlocal bufhidden=hide
      setlocal nobuflisted
      " setlocal winfixwidth
      " setlocal winfixheight
      " setlocal noequalalways
    endif

    call self.opts.OnOpenSplit()
    call self.opts.OnCreate()
    exec 'file ' . self.opts.BufNamePrefix . string(len(self.opts.buffers) + 1)
    call self.RegisterBuffer()
    let self.opts.index = len(self.opts.buffers) - 1
    call self.opts.OnOpen()
  endfunction

  function! l:instance.Close() dict
    if !self.IsOpen()
      return
    endif

    call self.Focus()
    call self.StoreSize()
    q
  endfunction

  " TODO
  " I think at this point that Open, CreateNew, and Go do the same thing in
  " slightly different ways:
  " - open or focus the split
  " - create or load an existing buffer
  function! l:instance.Go(num) dict
    let l:next_index = self.opts.index + a:num
    if l:next_index > len(self.opts.buffers) - 1
      let l:next_index = 0
    endif
    if l:next_index < 0
      let l:next_index = len(self.opts.buffers) - 1
    endif

    call self.Open(0)
    call self.Focus()
    exec 'buffer ' . self.opts.BufNamePrefix . string(l:next_index + 1)
    let self.opts.index = l:next_index
    call self.opts.OnOpen()
  endfunction

  " TODO
  " I think at this point that Open, CreateNew, and Go do the same thing in
  " slightly different ways:
  " - open or focus the split
  " - create or load an existing buffer
  function! l:instance.GoTo(num) dict
    let l:next_index = a:num
    if l:next_index > len(self.opts.buffers) - 1
      let l:next_index = 0
    endif
    if l:next_index < 0
      let l:next_index = len(self.opts.buffers) - 1
    endif

    call self.Open(0)
    call self.Focus()
    exec 'buffer ' . self.opts.buffers[l:next_index]
    let self.opts.index = l:next_index
    call self.opts.OnOpen()
  endfunction

  function! l:instance.IsOpen() dict
    return self.GetWinNum() != -1
  endfunction

  function! l:instance.GetWinNum() dict
    " Search all windows.
    for w in range(1,winnr('$'))
      if self.IsBuffer(bufname(winbufnr(w)))
        return w
      endif
    endfor

    return -1
  endfunction

  function! l:instance.DoesExist() dict
    " TODO needs to support multiple buffers
    return bufnr(self.opts.BufNamePrefix . '1') != -1
  endfunction

  function! l:instance.IsBuffer(name) dict
    return bufname(a:name) =~# '^' . self.opts.BufNamePrefix . '\d\+$'
  endfunction

  function! l:instance.Focus() dict
    if self.IsOpen()
      " wincmd w seems to focus the wrong window if this is called from the
      " terminal itself.
      " TODO this may need to actualy determine if called from a terminal, not
      " just a quick_terminal_, if we want better integration with plain ol'
      " terminals.
      if self.IsFocused()
        return
      endif

      exec self.GetWinNum() . 'wincmd w'
    endif
  endfunction

  function! l:instance.IsFocused() dict
    return self.IsBuffer(bufnr())
  endfunction

  function! l:instance.Unfocus() dict
    " if self.IsBuffer(bufname())
    "   " wincmd p
    "   1wincmd w
    " endif
    call DrawerGotoPreviousOrFirst()
  endfunction

  " Adapted from nuake
  function! l:instance.Look() dict
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

    return l:mode . self.GetSize()
  endfunction

  function! l:instance.StoreSize() dict
    let l:size = winheight(0)

    if self.opts.Position == 'left' || self.opts.Position == 'right'
      let l:size = winwidth(0)
    endif

    let self.opts.last_size = l:size
  endfunction

  function! l:instance.RestoreSize() dict
    let l:command = 'resize'
    if self.opts.Position == 'left' || self.opts.Position == 'right'
      let l:command = 'vertical resize'
    endif

    exec l:command . ' ' . self.GetSize()
  endfunction

  function! l:instance.GetSize() dict
    return self.opts.last_size != 0
          \ ? self.opts.last_size
          \ : self.opts.Size
  endfunction

  function! l:instance.GetCacheTabVarName() dict
    return 't:drawer_' . self.opts.BufNamePrefix
  endfunction

  call add(s:instances, l:instance)

  return l:instance
endfunction

function! s:autocmd_tableave()
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

  call DrawerGotoPreviousOrFirst()
endfunction

autocmd TabLeave * call s:autocmd_tableave()

function! s:autocmd_tabenter()
  " Since we do a lot to maintain the fact that ...
  " - no drawer is selected when a tab is left
  " - the previous window (or first) was selected when unfocusing
  " ... it means we don't have to muck around with anything when loading a
  " tab. Just grab the current window, set everything up again, and select
  " that same window.
  let l:winnr = winnr()

  for instance in s:instances
    let l:size = instance.GetSize()

    if instance.opts.was_open_before_tabchange
      call instance.Open(0)
      call instance.Focus()
      call instance.RestoreSize()
    else
      call instance.Close()

      " HACK the close may have overwritten the last size, it shouldn't here
      " so fuck it
      let instance.opts.last_size = l:size
    endif
  endfor

  exec l:winnr . 'wincmd w'
  " call DrawerGotoPreviousOrFirst()
endfunction

autocmd TabEnter * call s:autocmd_tabenter()

function! s:autocmd_bufenter()
  let l:total_open = len(filter(s:instances, 'v:val.IsOpen()'))

  if winnr("$") == l:total_open
    if tabpagenr('$') > 1
      tabclose
    else
      qa
    endif
  endif
endfunction

autocmd BufEnter * call s:autocmd_bufenter()

function! IsBufnrDrawer(bufnr)
  for instance in s:instances
    if instance.IsBuffer(a:bufnr)
      return 1
    endif
  endfor

  return 0
endfunction

function! DrawerGotoPreviousOrFirst()
  " vim only knows the previous selected window, and without a proper stack,
  " there's no reliable way to 'go back to the last non-drawer window'.
  " So all we can do is go to the previous window, and if that's also a
  " drawer, go to the first.
  " TODO That's also not guaranteed to work. Might need something like
  " 'FindFirstNonDrawerWindow()'.

  wincmd p
  if IsBufnrDrawer(bufnr())
    1wincmd w
  endif
endfunction
