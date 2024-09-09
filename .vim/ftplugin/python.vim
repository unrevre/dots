let b:ale_linters = ['pylsp', 'ruff']

let &l:makeprg = 'python %'
let &l:errorformat = '%-GTraceback%.%#,%E  File "%f"\, line %l%*\D%*[^ ] %m,'
