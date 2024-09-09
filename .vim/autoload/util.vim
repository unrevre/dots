function! util#guess()
  let view = winsaveview()
  silent! 0/^\t\%(\s*$\)\@!/
  let tabs = getline('.') =~ '^\t\%(\s*$\)\@!'
  silent! 0/^ \{2,4}\S/
  let spaces = len(matchstr(getline('.'), '^ \{2,4}\ze\S'))
  let &l:shiftwidth = spaces ? spaces : (tabs ? 0 : &sw)
  let &l:softtabstop = -1
  let &l:expandtab = !tabs
  call winrestview(view)
endfunction

function! util#repeat(...) abort
  execute (a:0 ? "'[,']" : "'<,'>").'normal @'.nr2char(getchar())
endfunction

function! util#sort(type, ...)
  '[,']sort
endfunction

function! util#break() abort
  s/^\(\s*\)\(.\{-}\)\(\s*\)\(\%#\)\(\s*\)\(.*\)/\1\2\r\1\4\6
  call histdel("/", -1)
endfunction

function! util#vsearch()
  let l:oldreg = getreg('"')
  let l:oldregtype = getregtype('"')
  normal gvy
  let l:selection = getreg('"')
  call setreg('"', l:oldreg, l:oldregtype)
  execute "norm \<Esc>"

  call setreg('/', substitute(l:selection, '\_s\+', '\\_s\\+', 'g'))
endfunction

function! util#abbrev(cmd, abbr)
  return (getcmdtype() ==# ':' && getcmdline() ==# a:abbr) ? a:cmd : a:abbr
endfunction

function! util#grep(...)
  if exists('b:git_base_path') && b:git_base_path !=# ''
    let grepprg = 'git grep --line-number $*'
  else
    let grepprg = &grepprg
  endif
  let grepprg = substitute(grepprg, '\V$*', expandcmd(join(a:000, ' ')), ' ')
  return system(grepprg)
endfunction

function! util#prompt(cmd)
  if a:cmd =~ '\C^buffers'
    let prompt = ':b '
  elseif a:cmd =~ '\C^marks'
    let prompt = ':norm! ` '
  elseif a:cmd =~ '\C^jumps'
    let prompt = ':norm! '
  elseif a:cmd =~ '\v\C/#$'
    let prompt = ':'
  elseif a:cmd =~ '\v\C^(clist|llist)'
    let prompt = ':silent '.repeat(a:cmd[0], 2)."\<Space>"
  elseif a:cmd =~ '\v\C^(dlist|ilist)'
    let prompt = ':'.a:cmd[0].'jump '.split(a:cmd, ' ')[1]."\<S-Left>\<Left>"
  endif

  if exists('prompt')
    call feedkeys(':'.a:cmd."\<CR>".prompt)
  else
    execute a:cmd
  endif
endfunction
