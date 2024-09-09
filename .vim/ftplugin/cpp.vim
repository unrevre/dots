let b:ale_linters = ['clangd']

let &l:makeprg = 'g++ -S -x c++ -fsyntax-only -Wall --std=c++11 %'
