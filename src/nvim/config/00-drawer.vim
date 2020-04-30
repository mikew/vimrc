let s:instances = []

function! CreateDrawer(opts)
  let a:opts.last_size = 0
  let a:opts.was_open_before_tabchange = 0

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
    execute self.Look() . 'new'
    setlocal bufhidden=hide
    setlocal nobuflisted
    setlocal winfixwidth
    setlocal winfixheight

    if a:should_start_terminal
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
    if !self.IsOpen()
      return
    endif

    call self.Focus()
    call self.StoreSize()
    q
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
      if self.IsBuffer(bufnr())
        return
      endif

      exec self.GetWinNum() . 'wincmd w'
    endif
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

    let l:size = self.opts.last_size != 0
          \ ? self.opts.last_size
          \ : self.opts.Size
    return l:mode . l:size
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
  let l:total_open = 0
  for instance in s:instances
    if instance.IsOpen()
      let l:total_open = l:total_open + 1
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

  wincmd p
  if IsBufnrDrawer(bufnr())
    1wincmd w
  endif
endfunction

autocmd BufEnter * call s:autocmd_bufenter()
