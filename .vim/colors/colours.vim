" vi:syntax=vim

" Theme setup
highlight clear
syntax reset
let g:colors_name = "colours"

" Customise highlights
highlight! Error        ctermfg=0   ctermbg=7
highlight! Folded       ctermfg=7   ctermbg=9
highlight! LineNr       ctermfg=12  ctermbg=8
highlight! MatchParen   ctermfg=0   ctermbg=3
highlight! Pmenu        ctermfg=0   ctermbg=3
highlight! PmenuSel     ctermfg=0   ctermbg=11
highlight! Search       ctermfg=12  ctermbg=3
highlight! Statement    ctermfg=11
highlight! Visual       ctermfg=3   ctermbg=8

highlight! User1        ctermfg=7   ctermbg=6   cterm=bold
highlight! User2        ctermfg=7   ctermbg=3   cterm=bold
highlight! User3        ctermfg=7   ctermbg=1   cterm=bold
highlight! User4        ctermfg=7   ctermbg=2   cterm=bold
highlight! User5        ctermfg=7   ctermbg=5   cterm=bold
highlight! User6        ctermfg=7   ctermbg=11  cterm=bold
highlight! User7        ctermfg=7   ctermbg=12  cterm=bold
highlight! User8        ctermfg=7   ctermbg=8
highlight! User9        ctermfg=7   ctermbg=9

highlight! link FoldColumn          Folded
highlight! link SignColumn          LineNr
highlight! link StatusLineTerm      StatusLine
highlight! link StatusLineTermNC    StatusLineNC
