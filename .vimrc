" vim:set et sw=2

execute pathogen#infect()

" ale
" fzf
" targets.vim
" vim-after-object
" vim-bufkill
" vim-commentary
" vim-cool
" vim-easy-align
" vim-exchange
" vim-matchup
" vim-peekaboo
" vim-pencil
" vim-qf
" vim-repeat
" vim-surround
" vim-tradewinds
" vim-usnip
" vim-vinegar
" vimagit

" general settings {{{
filetype plugin indent on
syntax on

set background=light
set encoding=utf-8

set autoindent
set expandtab
set formatoptions+=j
set nojoinspaces
set shiftwidth=4
set smarttab
set tabstop=8

set ttimeout
set ttimeoutlen=10

set backspace=indent,eol,start

set display+=lastline
set fillchars=vert:\ ,fold:-
set foldmethod=marker
set hidden
set hlsearch
set incsearch
set laststatus=2
set noshowmode
set nrformats-=octal
set numberwidth=5
set relativenumber
set scrolloff=1
set shortmess-=S
set signcolumn=number

set history=256
set sessionoptions-=options

set wildmenu

" runtime macros/matchit.vim

let mapleader = ' '
let maplocalleader = ' '

let g:tex_flavor = "latex"

let g:netrw_keepdir = 0
" }}}

" key bindings {{{
nnoremap <silent> <C-j> :move +1<CR>
nnoremap <silent> <C-k> :move -2<CR>
nnoremap <silent> <C-l> :nohlsearch<C-r>=has('diff') ? '<bar> diffupdate' : ''
      \ <CR><CR><C-l>

nnoremap ]b :bnext<CR>
nnoremap [b :bprev<CR>
nnoremap ]t :tabn<CR>
nnoremap [t :tabp<CR>

nnoremap <silent> gb :<C-u>call util#break()<CR>
nnoremap gd :Jump diff<CR>
nnoremap gm :Jump merge<CR>
nnoremap gp p`[
nnoremap gP P`[
nnoremap gq gw
nnoremap <silent> gr :set opfunc=util#repeat<CR>g@
nnoremap <silent> gs :set opfunc=util#sort<CR>g@
nnoremap gw :Grep <cword> %<CR>
nnoremap <silent> gz
      \ :let _s=@/ <bar> :%s/\s\+$//e <bar>
      \ :let @/=_s <bar> :nohl <bar>
      \ :unlet _s<CR>

nnoremap Q gq
nnoremap Y y$

nnoremap <leader>e :Explore<CR>
nnoremap <leader>p :set paste!<CR>
nnoremap <leader>q :quit<CR>
nnoremap <leader>t :set relativenumber!<CR>
nnoremap <leader>u :update<CR>
nnoremap <leader>. :let @/=@"<CR>/<CR>cgn<C-r>.<Esc>
nnoremap <leader>/ :execute 'vimgrep /'.@/.'/g %'<CR>:copen<CR>

inoremap <C-u> <C-g>u<C-u>
inoremap <C-j> <C-n>
inoremap <C-k> <C-p>
inoremap <expr> <CR> pumvisible() ? '<C-y><CR>' : '<CR>'

xnoremap <silent> <C-j> :move '>+1<CR>gv
xnoremap <silent> <C-k> :move -2<CR>gv

xnoremap . :normal .<CR>
xnoremap @ :<C-u>call util#repeat()<CR>

vnoremap <silent> * :call util#vsearch()<CR>/<CR>
vnoremap <silent> # :call util#vsearch()<CR>?<CR>

cnoremap <C-a> <Home>

tnoremap <C-n> <C-\><C-n>
" }}}

" commands {{{
command! -nargs=1 Count execute '%s/'.escape(<q-args>, '/').'//gn' | nohl
command! -nargs=0 -bar -range=% Reverse <line1>,<line2>g/^/m<line1>-1 | nohl

command! -nargs=* -complete=file Make silent call async#run(&makeprg, <f-args>)
command! -nargs=0 Stop silent call async#stop(<f-args>)

command! -nargs=0 -range Blame call git#blame(<range>, <line1>, <line2>)
command! -nargs=+ -bar -complete=file Grep cgetexpr util#grep(<f-args>)
command! -nargs=* -bar Jump cexpr system('git jump --stdout '.expand(<q-args>))
command! -nargs=+ -complete=command Prompt call util#prompt(<q-args>)
command! -nargs=1 -complete=command -range Scratch silent call
      \ scratch#window('16new', <q-args>, <range>, <line1>, <line2>)

command! -nargs=0 HL echo
      \ { l, c, n ->
        \ 'hi<'    . synIDattr(synID(l, c, 1), n)             . '> ' .
        \ 'trans<' . synIDattr(synID(l, c, 0), n)             . '> ' .
        \ 'lo<'    . synIDattr(synIDtrans(synID(l, c, 1)), n) . '> '
      \ }(line("."), col("."), "name")
" }}}

" abbreviations {{{
for [key, val] in items({
      \ 'B':        'b',
      \ 'E':        'e',
      \ 'H':        'h',
      \ 'Q':        'q',
      \ 'W':        'w',
      \ 'Set':      'set',
      \
      \ 'ct':       'terminal ++curwin',
      \ 'vt':       'vertical terminal',
      \ 'xt':       'terminal',
      \ 'hg':       'helpgrep',
      \
      \ 'grep':     'Grep',
      \
      \ 'ls':       'Prompt buffers',
      \ 'g':        'Prompt g',
      \ 'dlist':    'Prompt dlist',
      \ 'ilist':    'Prompt ilist',
      \ 'clist':    'Prompt clist',
      \ 'llist':    'Prompt llist',
      \ 'jumps':    'Prompt jumps',
      \ 'marks':    'Prompt marks',
      \ })
  execute 'cnoreabbrev <expr> '.key.' util#abbrev("'.val.'", "'.key.'")'
endfor
" }}}

" autocommands {{{
augroup guess
  autocmd!
  autocmd StdinReadPost,FilterReadPost,FileReadPost,BufReadPost
        \ * call util#guess()
augroup END

augroup git
  autocmd!
  autocmd BufNewFile,BufReadPost * call git#detect(expand('<amatch>:p:h'))
  autocmd BufEnter * call git#detect(expand('%:p:h'))
augroup END

augroup status
  autocmd!
  autocmd VimEnter,WinEnter,BufEnter * call status#refresh()
augroup END
" }}}

" text objects {{{
" buffer object {{{
xnoremap i% GoggV
onoremap i% :normal vi%<CR>
" }}}

" fold object {{{
xnoremap iz :<C-u>silent! normal! [zV]z<CR>
onoremap iz :normal viz<CR>
" }}}

" indent object {{{
xnoremap ii :<C-u>call textobj#indent(0)<CR>
onoremap ii :<C-u>call textobj#indent(0)<CR>
xnoremap ai :<C-u>call textobj#indent(1)<CR>
onoremap ai :<C-u>call textobj#indent(1)<CR>
" }}}

" comment object {{{
xmap <silent> ic :<C-u>call textobj#comment(1)<CR>
omap <silent> ic :<C-u>call textobj#comment(0)<CR>
" }}}

" line object {{{
xnoremap il g_o^
onoremap il :normal vil<CR>
xnoremap al $o0
onoremap al :normal val<CR>
" }}}

" path object {{{
xnoremap <silent> if
      \ :<C-u>
      \ let pr='\(\/\([0-9a-zA-Z_\-\.]\+\)\)\+' <bar>
      \ let l=line('.') <bar>
      \ let epos = searchpos(pr, 'ceW', l) <bar>
      \ if epos == [0, 0] <bar>
      \ let epos = searchpos(pr, 'bceW', l) <bar>
      \ endif <bar>
      \ let spos = searchpos('\f\+', 'bcW', l) <bar>
      \ call textobj#select(spos, epos)<CR>
onoremap <silent> if :normal vif<CR>
" }}}

" search pattern object {{{
xnoremap <silent> i/
      \ :<C-u>
      \ let spos = searchpos(@\, 'c') <bar>
      \ let epos = searchpos(@\, 'ce') <bar>
      \ :call textobj#select(spos, epos)<CR>
onoremap <silent> i/ :normal vi/<CR>
xnoremap <silent> i?
      \ :<C-u>
      \ let spos = searchpos(@\, 'bc') <bar>
      \ let epos = searchpos(@\, 'ce') <bar>
      \ :call textobj#select(spos, epos)<CR>
onoremap <silent> i? :normal vi?<CR>
" }}}
" }}}

" highlight groups {{{
function! s:customise_highlight_groups()
  highlight! MatchWord      ctermfg=0     ctermbg=3

  highlight! ALEError       ctermfg=0     ctermbg=7
  highlight! ALEErrorSign   ctermfg=1     ctermbg=9
  highlight! ALEInfo        ctermfg=none  ctermbg=8
  highlight! ALEInfoSign    ctermfg=2     ctermbg=9
  highlight! ALEWarning     ctermfg=0     ctermbg=11
  highlight! ALEWarningSign ctermfg=3     ctermbg=9
endfunction!

autocmd! ColorScheme * call s:customise_highlight_groups()

colorscheme colours
" }}}

" plugin settings {{{
" after-object {{{
autocmd VimEnter * call after_object#enable(
      \ ['[', ']'],
      \ '+', '-', '*', '/', '%', '@',
      \ '&', '|', '^',
      \ '=', ':',
      \ '#', '"',
      \ ',', '.', '?',
      \ )
" }}}

" ale {{{
let g:ale_completion_enabled = 1
let g:ale_echo_msg_format = '[%linter%] %s'
let g:ale_floating_preview = 1
let g:ale_lint_delay = 800
let g:ale_linters_explicit = 1
let g:ale_set_loclist = 1
let g:ale_sign_error = ' ●'
let g:ale_sign_info = ' ●'
let g:ale_sign_warning = ' ●'
let g:ale_warn_about_trailing_whitespace = 0

autocmd BufRead,FileType * call plugins#ale_maps()
" }}}

" bufkill {{{
let g:BufKillCreateMappings = 0

nnoremap <silent> <leader>d :execute winnr() == winnr('$') ? 'bd' : 'BD' <CR>
" }}}

" easy-align {{{
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)
" }}}

" exchange {{{
vmap x <Plug>(Exchange)
" }}}

" fzf {{{
function! s:insert(lines)
  let @@ = fnamemodify(a:lines[0], ":p")
  normal! p
endfunction

let g:fzf_action = {
      \ 'ctrl-f': function('s:insert'),
      \ 'ctrl-x': 'split',
      \ 'ctrl-v': 'vsplit',
      \ }
let g:fzf_layout = {
      \ 'window': {
        \ 'width': 1.0,
        \ 'height': 0.4,
        \ 'relative': v:true,
        \ 'yoffset': 1.0,
        \ },
      \ }
let g:fzf_colors = {
      \ 'fg':      ['fg', 'Normal'],
      \ 'bg':      ['bg', 'Normal'],
      \ 'hl':      ['fg', 'Visual'],
      \ 'hl+':     ['fg', 'Constant'],
      \ 'info':    ['fg', 'Type'],
      \ 'border':  ['fg', 'Visual'],
      \ 'prompt':  ['fg', 'Statement'],
      \ 'pointer': ['fg', 'Constant'],
      \ 'marker':  ['fg', 'Statement'],
      \ 'spinner': ['fg', 'Comment'],
      \ 'header':  ['fg', 'Comment'],
      \ }

command! -complete=dir -nargs=? FZG call plugins#fzf_git_ls(<f-args>)
command! -nargs=0 FZH call plugins#fzf_history()
command! -bar -complete=buffer -nargs=? FZB call plugins#fzf_buffers(<q-args>)

nnoremap <leader>f :FZF<CR>
nnoremap <leader>g :FZG<CR>
nnoremap <leader>h :FZH<CR>
nnoremap <leader>b :FZB<CR>
" }}}

" magit {{{
let g:magit_stage_hunk_mapping = 's'
let g:magit_commit_mapping = 'cm'
let g:magit_commit_amend_mapping = 'ca'
let g:magit_commit_fixup_mapping = 'cf'
let g:magit_close_commit_mapping = 'cq'
let g:magit_discard_hunk_mapping = 'd'
let g:magit_ignore_mapping = 'i'
let g:magit_jump_next_hunk = 'n'
let g:magit_jump_prev_hunk = 'N'
let g:magit_update_mode = 'fast'

let g:magit_git_cmd = 'git'
let g:magit_show_magit_display = 'c'

nnoremap <leader>m :<C-u>Magit<CR>
" }}}

" matchup {{{
let g:matchup_delim_stopline = 3200
let g:matchup_matchparen_stopline = 800
let g:matchup_matchparen_offscreen = {'method': 'popup'}
let g:matchup_motion_cursor_end = 0
let g:matchup_motion_override_Npercent = 0

nnoremap <leader>i :<C-u>MatchupWhereAmI??<CR>
" }}}

" pencil {{{
let g:pencil#concealcursor = 'nc'
let g:pencil#textwidth = 79

augroup pencil
  autocmd!
  autocmd FileType markdown,text call pencil#init()
augroup END
" }}}

" peekaboo {{{
let g:peekaboo_window = 'vertical botright 40new'
" }}}

" qf {{{
nmap ]c <Plug>(qf_qf_next)
nmap [c <Plug>(qf_qf_previous)
nmap ]l <Plug>(qf_loc_next)
nmap [l <Plug>(qf_loc_previous)
nmap <leader>c <Plug>(qf_qf_toggle_stay)
nmap <leader>l <Plug>(qf_qf_toggle_stay)
" }}}

" targets {{{
let g:targets_nl = 'jk'
" }}}
" }}}
