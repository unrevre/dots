execute pathogen#infect()

" vim-commentary
" vim-easyalign
" vim-flame
" vim-peekaboo
" vim-qf
" vim-surround
" vim-tradewinds
" vim-usnip
" vimagit

" general settings {{{
filetype plugin indent on
syntax on

colorscheme colours

set background=light
set encoding=utf-8

set tabstop=8
set shiftwidth=4
set smarttab
set expandtab
set autoindent

set ttimeout
set ttimeoutlen=10

set backspace=indent,eol,start
set formatoptions+=j
set nojoinspaces

set incsearch
set hlsearch
set noshowmode
set laststatus=2
set display+=lastline
set scrolloff=1
set fillchars=vert:\ ,fold:-
set foldmethod=marker
set numberwidth=5
set relativenumber

set hidden
set sessionoptions-=options
set history=512
set tabpagemax=16

set wildmenu

runtime macros/matchit.vim

let mapleader = ' '
let maplocalleader = ' '

let g:tex_flavor = "latex"
" }}}

" key bindings {{{
nnoremap <silent> <C-l> :nohlsearch<C-r>=has('diff')
        \ ?'<Bar>diffupdate':''<CR><CR><C-l>

nnoremap <silent> @R :set operatorfunc=util#repeat<CR>g@

nnoremap ]b :bnext<CR>
nnoremap [b :bprev<CR>
nnoremap ]t :tabn<CR>
nnoremap [t :tabp<CR>

nnoremap <silent> gb :<C-u>call util#break()<CR>
nnoremap <silent> gw :let _s=@/ <Bar> :%s/\s\+$//e <Bar>
        \ :let @/=_s <Bar> :nohl <Bar> :unlet _s<CR>

nnoremap Q @q
nnoremap Y y$

nnoremap <leader>e :e <C-r>=expand("%:p:h").'/'<CR>
nnoremap <leader>q :quit<CR>
nnoremap <leader>t :set relativenumber!<CR>
nnoremap <leader>u :update<CR>
nnoremap <leader>w <C-w>
nnoremap <leader>. :let @/=@"<CR>/<CR>cgn<C-r>.<Esc>
nnoremap <leader>/ :execute 'vimgrep /'.@/.'/g %'<CR>:copen<CR>

inoremap <C-u> <C-g>u<C-u>

xnoremap . :normal .<CR>
xnoremap @ :<C-u>call util#repeat()<CR>

vnoremap <silent> *
        \ :<C-u>
        \ let old_reg=getreg('"')<Bar>
        \ let old_regtype=getregtype('"')<CR>
        \ gvy/<C-r><C-r>=substitute(
        \ escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
        \ gV
        \ :call setreg('"', old_reg, old_regtype)<CR>
vnoremap <silent> #
        \ :<C-u>
        \ let old_reg=getreg('"')<Bar>
        \ let old_regtype=getregtype('"')<CR>
        \ gvy?<C-r><C-r>=substitute(
        \ escape(@", '?\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
        \ gV
        \ :call setreg('"', old_reg, old_regtype)<CR>

cnoremap <C-a> <Home>
" }}}

" commands {{{
command! -nargs=1 Count execute printf('%%s/%s//gn', escape(<q-args>, '/'))
        \ | normal! ``
command! -nargs=* -complete=file Make
        \ :silent call async#run(&makeprg, <f-args>)
command! -nargs=0 Stop
        \ :silent call async#stop(<f-args>)
" }}}

" autocommands {{{
augroup guess
    autocmd!
    autocmd StdinReadPost,FilterReadPost,FileReadPost,BufReadPost
            \ * call start#guess()
augroup END

augroup lint
    autocmd!
    autocmd FileType asm
            \ let &l:makeprg='gcc -x assembler -fsyntax-only'
    autocmd FileType c
            \ let &l:makeprg='gcc -S -x c -fsyntax-only -Wall'
    autocmd FileType cpp
            \ let &l:makeprg='g++ -S -x c++ -fsyntax-only -Wall --std=c++14'
    autocmd BufWritePost *.S,*.c,*.cpp Make
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
" cancel object {{{
noremap <Plug>(EmptyObject) <Nop>
inoremap <expr> <Plug>(EmptyObject) exists('#emptyobj')?"\<Esc>":''
" }}}

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
xmap <silent> ic :<C-u>call textobj#comment(1)<CR><Plug>(EmptyObject)
omap <silent> ic :<C-u>call textobj#comment(0)<CR><Plug>(EmptyObject)
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
        \ let pr='\(\/\([0-9a-zA-Z_\-\.]\+\)\)\+' <Bar>
        \ let l=line('.') <Bar>
        \ let epos = searchpos(pr, 'ceW', l) <Bar>
        \ if epos == [0, 0] <Bar>
        \ let epos = searchpos(pr, 'bceW', l) <Bar>
        \ endif <Bar>
        \ let spos = searchpos('\f\+', 'bcW', l) <Bar>
        \ call textobj#select(spos, epos)<CR>
onoremap <silent> if :normal vif<CR>
" }}}

" search pattern object {{{
xnoremap <silent> i/
        \ :<C-u>
        \ let spos = searchpos(@\, 'c') <Bar>
        \ let epos = searchpos(@\, 'ce') <Bar>
        \ :call textobj#select(spos, epos)<CR>
onoremap <silent> i/ :normal vi/<CR>
xnoremap <silent> i?
        \ :<C-u>
        \ let spos = searchpos(@\, 'bc') <Bar>
        \ let epos = searchpos(@\, 'ce') <Bar>
        \ :call textobj#select(spos, epos)<CR>
onoremap <silent> i? :normal vi?<CR>
" }}}
" }}}

" highlight groups {{{
highlight! User1 ctermfg=7 ctermbg=6 cterm=bold
highlight! User2 ctermfg=7 ctermbg=3 cterm=bold
highlight! User3 ctermfg=7 ctermbg=1 cterm=bold
highlight! User4 ctermfg=7 ctermbg=2 cterm=bold
highlight! User5 ctermfg=7 ctermbg=5 cterm=bold
highlight! User6 ctermfg=7 ctermbg=8
highlight! User7 ctermfg=7 ctermbg=9

highlight! LineNr ctermfg=12 ctermbg=8
" }}}

" plugin settings {{{
" easyalign {{{
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)
" }}}

" flame {{{
nmap gl <Plug>(FlameLine)
" }}}

" magit {{{
let g:magit_show_magit_mapping = '<leader>m'
let g:magit_stage_hunk_mapping = 's'
let g:magit_commit_mapping = 'cm'
let g:magit_commit_amend_mapping = 'ca'
let g:magit_commit_fixup_mapping = 'cf'
let g:magit_close_commit_mapping = 'cq'
let g:magit_ignore_mapping = "<Nop>"
let g:magit_jump_next_hunk = 'n'
let g:magit_jump_prev_hunk = 'N'

let g:magit_git_cmd = 'git'
" }}}

" peekaboo {{{
let g:peekaboo_window = 'vert bo 40new'
" }}}

" qf {{{
nmap ]c <Plug>(qf_qf_next)
nmap [c <Plug>(qf_qf_previous)
nmap ]l <Plug>(qf_loc_next)
nmap [l <Plug>(qf_loc_previous)
" }}}
" }}}
