function! s:colour(active, group, content) abort
  let higroup = a:active ? a:group : 8
  return '%' . higroup . '*' . a:content
endfunction

function! s:mode() abort
  let m = mode()
  if m ==# 'n'
    return 1
  elseif m ==? 'v' || m ==? "\<C-v>"
    return 4
  elseif m ==? 's' || m ==? "\<C-s>"
    return 5
  elseif m ==# 'i'
    return 2
  elseif m ==# 'R'
    return 3
  elseif m ==# 't'
    return 6
  elseif m ==# 'c'
    return 7
  else
    return 8
  endif
endfunction

function! status#line(win) abort
  let active = a:win == winnr()

  let stat = ''
  let stat .= s:colour(active, s:mode(), '%( %3l %)')
  let stat .= s:colour(active, 8, '%( %<%f%m %r %)')
  let stat .= '%='
  let stat .= s:colour(active, 8, '%( %{git#branch()} %)')
  let stat .= s:colour(active, 9, '%( %2c %)')

  return stat
endfunction

function! status#refresh() abort
  for nr in range(1, winnr('$'))
    call setwinvar(nr, '&statusline', '%!status#line(' . nr . ')')
  endfor
endfunction
