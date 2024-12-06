function! plugins#ale_maps()
  let l:lsp_found = 0
  for l:linter in ale#linter#Get(&filetype)
    if !empty(l:linter.lsp)
      let l:lsp_found = 1
      break
    endif
  endfor

  if (l:lsp_found)
    nnoremap <C-n> :ALEHover<CR>
    nnoremap <buffer> <C-]> :ALEGoToDefinition<CR>
    nnoremap <buffer> <C-\> :ALEFindReferences<CR>
  else
    silent! unmap <buffer> <C-n>
    silent! unmap <buffer> <C-]>
    silent! unmap <buffer> <C-\>
  endif
endfunction

function! plugins#fzf_git_ls(...)
  if !exists('b:git_base_path') || b:git_base_path ==# ''
    echo ' [w] .git directory not found [b:git_base_path]'
    return
  endif

  let dir = get(a:, 1, b:git_base_path)
  call fzf#run(fzf#wrap({
        \ 'source': 'git ls-files ' . dir,
        \ 'dir': dir,
        \ 'options': '--prompt="[git] " --layout=default',
        \ }))
endfunction

function! s:strip(str)
  return substitute(a:str, '^\s*\|\s*$', '', 'g')
endfunction

function! s:rstrip(str)
  return substitute(a:str, '\s*$', '', 'g')
endfunction

function! s:get_colour(attr, group)
  let code = synIDattr(synIDtrans(hlID(a:group)), a:attr, 'cterm')
  if code =~? '^[0-9]\+$'
    return code
  endif
  return ''
endfunction

function! s:highlight(str, group)
  let fg = s:get_colour('fg', a:group)
  let bg = s:get_colour('bg', a:group)
  let colour = '38;5;'.fg.';'.'48;5;'.bg
  return printf("\x1b[%s%sm%s\x1b[m", colour, a:0 ? ';1' : '', a:str)
endfunction

function! s:function(name)
  return function(a:name)
endfunction

function! s:wrap(opts)
  " fzf#wrap does not append --expect if sink or sink* is found
  let opts = copy(a:opts)
  let options = ''
  if has_key(opts, 'options')
    let options = type(opts.options) == type([]) ? join(opts.options) : opts.options
  endif
  if options !~ '--expect' && has_key(opts, 'sink*')
    let F_sink = remove(opts, 'sink*')
    let wrapped = fzf#wrap(opts)
    let wrapped['sink*'] = F_sink
  else
    let wrapped = fzf#wrap(opts)
  endif
  return wrapped
endfunction

function! s:history_source()
  let max = histnr(':')
  if max <= 0
    return ['[none]']
  endif
  let fmt = ' %'.len(string(max)).'d '
  let list = filter(map(range(1, max), 'histget(":", - v:val)'), '!empty(v:val)')
  return extend(
        \ [' :: [ctrl-l] to edit'],
        \ map(list, 'printf(fmt, len(list) - v:key)." ".v:val'),
        \ )
endfunction

nnoremap <Plug>(-fzf-execute) :execute g:__fzf_command<cr>
nnoremap <Plug>(-fzf-:) :

function! s:history_sink(lines)
  if len(a:lines) < 2
    return
  endif

  let prefix = "\<Plug>(-fzf-:)"
  let key  = a:lines[0]
  let item = matchstr(a:lines[1], ' *[0-9]\+ *\zs.*')
  call histadd(':', item)
  if key == 'ctrl-l'
    redraw
    call feedkeys(":\<Up>", 'n')
  else
    let g:__fzf_command = "normal ".prefix.item."\<CR>"
    call feedkeys("\<Plug>(-fzf-execute)")
  endif
endfunction

function! plugins#fzf_history(...)
  return fzf#run(s:wrap({
        \ 'source': s:history_source(),
        \ 'sink*': s:function('s:history_sink'),
        \ 'options': [
          \ '+m',
          \ '--prompt=[q:] ',
          \ '--layout=default',
          \ '--header-lines=1',
          \ '--tiebreak=index',
          \ '--expect=ctrl-l',
          \ ],
        \ }))
endfunction

function! s:find_window(b)
  let [tcur, tcnt] = [tabpagenr() - 1, tabpagenr('$')]
  for toff in range(0, tabpagenr('$') - 1)
    let t = (tcur + toff) % tcnt + 1
    let buffers = tabpagebuflist(t)
    for w in range(1, len(buffers))
      let b = buffers[w - 1]
      if b == a:b
        return [t, w]
      endif
    endfor
  endfor
  return [0, 0]
endfunction

function! s:format_buffer(b)
  let name = bufname(a:b)
  let line = exists('*getbufinfo') ? getbufinfo(a:b)[0]['lnum'] : 0
  let fullname = empty(name) ? '' : fnamemodify(name, ":p:~:.")
  let dispname = empty(name) ? '[tmp]' : name
  let flag = a:b == bufnr('')  ? s:highlight('%', 'Conditional') :
        \ (a:b == bufnr('#') ? s:highlight('#', 'Special') : ' ')
  let modified = getbufvar(a:b, '&modified') ? s:highlight(' [+]', 'Exception') : ''
  let readonly = getbufvar(a:b, '&modifiable') ? '' : s:highlight(' [ro]', 'Constant')
  let extra = join(filter([modified, readonly], '!empty(v:val)'), '')
  let target = empty(name) ? '' : (line == 0 ? fullname : fullname.':'.line)
  return s:rstrip(printf("%s\t%d\t[%s] %s\t%s\t%s", target, line, s:highlight(a:b, 'Number'), flag, dispname, extra))
endfunction

function! s:jump(t, w)
  execute a:t.'tabnext'
  execute a:w.'wincmd w'
endfunction

function! s:execute_silent(cmd)
  silent keepjumps keepalt execute a:cmd
endfunction

" [key, [filename, [stay_on_edit: 0]]]
function! s:action_for(key, ...)
  let cmd = get(get(g:, 'fzf_action'), a:key, '')

  " See If the command is the default action that opens the selected file in
  " the current window. i.e. :edit
  let edit = stridx('edit', cmd) == 0 " empty, e, ed, ..

  " If no extra argument is given, we just execute the command and ignore
  " errors. e.g. E471: Argument required: tab drop
  if !a:0
    if !edit
      normal! m'
      silent! call s:execute_silent(cmd)
    endif
  else
    " For the default edit action, we don't execute the action if the
    " selected file is already opened in the current window, or we are
    " instructed to stay on the current buffer.
    let stay = edit && (a:0 > 1 && a:2 || fnamemodify(a:1, ':p') ==# expand('%:p'))
    if !stay
      normal! m'
      call s:execute_silent((len(cmd) ? cmd : 'edit').' '.s:escape(a:1))
    endif
  endif
endfunction

function! s:buffer_sink(lines)
  if len(a:lines) < 2
    return
  endif
  let b = matchstr(a:lines[1], '\[\zs[0-9]*\ze\]')
  if empty(a:lines[0])
    let [t, w] = s:find_window(b)
    if t
      call s:jump(t, w)
      return
    endif
  endif
  call s:action_for(a:lines[0])
  execute 'buffer' b
endfunction

function! s:sort_buffers(...)
  let [b1, b2] = map(copy(a:000), 'get(g:fzf_buffers, v:val, v:val)')
  " Using minus between a float and a number in a sort function causes an error
  return b1 < b2 ? 1 : -1
endfunction

function! plugins#fzf_buffers(...)
  let query = get(a:, 1, '')
  let sorted = sort(
        \ filter(
          \ range(1, bufnr('$')),
          \ 'buflisted(v:val) && getbufvar(v:val, "&filetype") != "qf"',
          \ ),
        \ 's:sort_buffers',
        \ )
  let arg_header_lines = '--header-lines=' . (bufnr('') == get(sorted, 0, 0) ? 1 : 0)
  let tabstop = len(max(sorted)) >= 4 ? 9 : 8
  return fzf#run(s:wrap({
        \ 'source': map(sorted, 's:format_buffer(v:val)'),
        \ 'sink*': s:function('s:buffer_sink'),
        \ 'options': [
          \ '+m',
          \ '--ansi',
          \ '--query', query,
          \ '--prompt=[:b] ',
          \ '--delimiter', '\t',
          \ '--layout=default',
          \ arg_header_lines,
          \ '--tiebreak=index',
          \ '--nth', '2,1..2',
          \ '--with-nth', '3..',
          \ '--tabstop', tabstop,
          \ ]
        \ }))
endfunction

if !exists('g:fzf_buffers')
  let g:fzf_buffers = {}
endif

augroup fzf_buffers
  autocmd!
  autocmd BufWinEnter,WinEnter * let g:fzf_buffers[bufnr('')] = reltimefloat(reltime())
  autocmd BufDelete * silent! call remove(g:fzf_buffers, expand('<abuf>'))
augroup END
