function! git#dir(path) abort
  let path = a:path
  let prev = ''
  while path !=# prev
    let dir = path . '/.git'
    let type = getftype(dir)
    if type ==# 'dir' && isdirectory(dir.'/objects') && isdirectory(dir.'/refs') && getfsize(dir.'/HEAD') > 10
      return path
    endif
    if type ==# 'file'
      let reldir = get(readfile(dir), 0, '')
      if reldir =~# '^gitdir: '
        return simplify(path . '/' . reldir[8:])
      endif
    endif
    let prev = path
    let path = fnamemodify(path, ':h')
  endwhile
  return ''
endfunction

function! git#detect(path) abort
  unlet! b:git_head_path
  let b:git_pwd = expand('%:p:h')
  let path = git#dir(a:path)
  if path !=# ''
    let dir = path . '/.git'
    let head = dir . '/HEAD'
    if filereadable(head)
      let b:git_base_path = path
      let b:git_head_path = head
      let b:git_dir_path = dir
    endif
  endif
endfunction

function! git#branch() abort
  if get(b:, 'git_pwd', '') !=# expand('%:p:h') || !has_key(b:, 'git_head_path')
    call git#detect(expand('%:p:h'))
  endif

  if !has_key(b:, 'git_head_path') || !filereadable(b:git_head_path)
    return ''
  endif

  let branch = get(readfile(b:git_head_path), 0, '')
  if branch =~# '^ref: '
    return substitute(branch, '^ref: \%(refs/\%(heads/\|remotes/\|tags/\)\=\)\=', '', '')
  endif
  if branch =~# '^\x\{20\}'
    return branch[:6]
  endif
endfunction

function! git#blame(range, line1, line2)
  if get(b:, 'git_pwd', '') !=# expand('%:p:h') || !has_key(b:, 'git_head_path')
    call git#detect(expand('%:p:h'))
  endif

  if !exists('b:git_base_path') || b:git_base_path ==# ''
    echo ' [w] .git directory not found [b:git_base_path]'
    return
  endif

  let cmd = matchstr(expandcmd('!git blame -f %'), '^!\zs.*')
  if a:range > 0
    let cmd = cmd . ' -L ' . a:line1 . ',' . a:line2
  endif
  let cmd = cmd . ' | sed -E "s/([0-9a-f^]+) .* \((.*) ([0-9\-]{10}) [0-9:]{8} [+-][0-9]{4} +[0-9]+\).*/\1 \3 \2/"'
  let output = systemlist(cmd)

  let curline = line('.')
  let winline = line('w0')
  setlocal scrollbind
  syncbind

  execute 'vertical leftabove 48new'
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
  call setline(1, output)
  call cursor(curline, 1)
  let shift = winline - line('w0')
  if shift > 0
    execute 'normal! ' . shift . "\<C-e>"
  endif
  setlocal nomodifiable scrollbind
endfunction
