# The MIT License (MIT)
#
# Copyright (c) 2024 Junegunn Choi
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

_fzf_wrapper() {
  fzf \
    --border-label-pos=2 \
    "$@"
}

_fzf_git_check() {
  git rev-parse HEAD > /dev/null 2>&1
  return $?
}

__fzf_git_pager() {
  local pager
  pager="${FZF_GIT_PAGER:-${GIT_PAGER:-$(git config --get core.pager 2>/dev/null)}}"
  echo "${pager:-cat}"
}

branches() {
  git branch --sort=-committerdate --sort=-HEAD --format=$'%(HEAD) %(color:yellow)%(refname:short) %(color:green)(%(committerdate:relative))\t%(color:blue)%(subject)%(color:reset)' | column -ts$'\t'
}

_fzf_git_branches() {
  _fzf_git_check || return
  branches |
  _fzf_wrapper \
    --ansi \
    --tiebreak begin \
    --no-hscroll \
    --border-label '🌲 Branches' |
  sed 's/^..//' | cut -d' ' -f1
}

hashes() {
  git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph
}

_fzf_git_hashes() {
  _fzf_git_check || return
  hashes |
  _fzf_wrapper \
    --height 40% \
    --ansi \
    --no-sort \
    --preview "grep -o '[a-f0-9]\{7,\}' <<< {} | head -n 1 | xargs -r git show --color=always | $(__fzf_git_pager)" \
    --border-label '🍡 Hashes' |
  awk 'match($0, /[a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9]*/) { print substr($0, RSTART, RLENGTH) }'
}

_fzf_git_stashes() {
  _fzf_git_check || return
  git stash list |
  _fzf_wrapper \
    --height 40% \
    -d: \
    --preview "git stash show -p --color=always {1} | $(__fzf_git_pager)" \
    --border-label '🥡 Stashes' |
  cut -d: -f1
}

__fzf_git_init() {
  local opt key
  for opt in "$@"; do
    key=${opt:0:1}
    bind -m emacs-standard '"\C-g\C-'"$key"'": " \C-u \C-a\C-k`_fzf_git_'"$opt"'`\e\C-e\C-y\C-a\C-y\ey\C-h\C-e\er \C-h"'
    bind -m vi-command     '"\C-g\C-'"$key"'": "\C-z\C-g\C-'"$key"'\C-z"'
    bind -m vi-insert      '"\C-g\C-'"$key"'": "\C-z\C-g\C-'"$key"'\C-z"'
  done
}

__fzf_git_init branches hashes stashes
