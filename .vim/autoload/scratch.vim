function! s:output(cmd, range, line1, line2)
  if a:cmd =~ '^!'
    let cmd = a:cmd =~ ' %'
          \ ? matchstr(substitute(a:cmd, ' %', ' ' . shellescape(escape(expand('%:p'), '\')), ''), '^!\zs.*')
          \ : matchstr(a:cmd, '^!\zs.*')
    if a:range == 0
      return systemlist(cmd)
    else
      let lines = join(getline(a:line1, a:line2), '\n')
      let lines = substitute(shellescape(lines), "'\\\\''", "\\\\'", 'g')
      return systemlist(cmd . " <<< $" . lines)
    endif
  else
    redir => output
    execute a:cmd
    redir END
    return split(output, "\n")
  endif
endfunction

function! scratch#window(wincmd, cmd, range, line1, line2)
  let output = <SID>output(a:cmd, a:range, a:line1, a:line2)

  for win in range(1, winnr('$'))
    if getwinvar(win, 'scratch')
      execute win . 'windo close'
    endif
  endfor

  execute a:wincmd
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
  call setline(1, output)
endfunction
