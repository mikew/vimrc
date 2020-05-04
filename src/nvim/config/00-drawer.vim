let s:instances = []

function! CreateDrawer(opts)
  let a:opts.last_size = 0
  let a:opts.was_open_before_tabchange = 0
  let a:opts.buffers = []
  let a:opts.previous_buffer = ''
  let a:opts.counter = 0

  let l:instance = {
        \ 'opts': a:opts,
        \ }

  function! l:instance.Toggle() dict
    if self.IsOpen()
      call self.Close()
    else
      call self.OpenMostRecent()
    endif
  endfunction

  function! l:instance.FocusOrToggle() dict
    if self.IsOpen()
      if self.IsFocused()
        call self.Close()
      else
        call self.Focus()
      endif
    else
      call self.OpenMostRecent()
    endif
  endfunction

  function! l:instance.OpenMostRecent() dict
    call self.OpenAndFocusSplit()
    let l:bufname = self.opts.previous_buffer
    if l:bufname == ''
      let l:bufname = self.NextBufName()
    endif
    call self.EditExisting(l:bufname)
  endfunction

  function! l:instance.CreateNew() dict
    call self.OpenAndFocusSplit()
    " TODO This needs to happen in case the split is already open when
    " CreateNew is called.
    enew
    call self.EditExisting(self.NextBufName())
  endfunction

  function! l:instance.NextBufName() dict
    let l:id = self.opts.counter + 1
    let self.opts.counter = l:id

    return self.opts.BufNamePrefix . string(l:id)
  endfunction

  function! l:instance.OpenAndFocusSplit() dict
    if self.IsOpen()
      call self.Focus()
      call self.RestoreSize()
      return
    endif

    execute self.Look() . ' new'
    call self.opts.OnOpenSplit()
  endfunction

  function! l:instance.EditExisting(bufname) dict
    if bufnr(a:bufname) == -1
      call self.opts.OnCreate()
      exec 'file ' . a:bufname
    else
      exec 'buffer ' . a:bufname
    endif
    call self.opts.OnOpen()
    setlocal bufhidden=hide
    setlocal nobuflisted
    setlocal winfixwidth
    setlocal winfixheight
    setlocal noequalalways

    let self.opts.previous_buffer = a:bufname
    call self.RegisterBuffer(a:bufname)
  endfunction

  function! l:instance.RegisterBuffer(bufname) dict
    if index(self.opts.buffers, a:bufname) == -1
      call add(self.opts.buffers, a:bufname)
    endif
  endfunction

  function! l:instance.Close() dict
    if !self.IsOpen()
      return
    endif

    call self.Focus()
    call self.StoreSize()
    q
  endfunction

  function! l:instance.Go(num) dict
    let l:index = index(self.opts.buffers, self.opts.previous_buffer)
    if self.opts.previous_buffer == ''
      let l:index = 0
    endif
    let l:next_index = l:index + a:num
    if l:next_index > len(self.opts.buffers) - 1
      let l:next_index = 0
    endif
    if l:next_index < 0
      let l:next_index = len(self.opts.buffers) - 1
    endif

    call self.OpenAndFocusSplit()
    call self.EditExisting(self.opts.BufNamePrefix . string(l:next_index + 1))
  endfunction

  function! l:instance.GoTo(num) dict
    let l:next_index = a:num
    if l:next_index > len(self.opts.buffers) - 1
      let l:next_index = 0
    endif
    if l:next_index < 0
      let l:next_index = len(self.opts.buffers) - 1
    endif

    call self.OpenAndFocusSplit()
    call self.EditExisting(self.opts.BufNamePrefix . string(l:next_index + 1))
  endfunction

  function! l:instance.IsOpen() dict
    return self.GetWinNum() != -1
  endfunction

  function! l:instance.GetWinNum() dict
    " Search all windows.
    for w in range(1, winnr('$'))
      if self.IsBuffer(bufname(winbufnr(w)))
        return w
      endif
    endfor

    return -1
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

  call add(s:instances, l:instance)

  return l:instance
endfunction

function! s:autocmd_tableave()
  for instance in s:instances
    if instance.IsOpen()
      let instance.opts.was_open_before_tabchange = 1
      call instance.Focus()
      call instance.StoreSize()
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
      call instance.OpenMostRecent()
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
  let l:total_open = 0
  for instance in s:instances
    if instance.IsOpen()
      let l:total_open += 1
    endif
  endfor

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
