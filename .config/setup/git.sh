#!/usr/bin/env bash

# editor
git config --global core.editor vim

# git aliases
git config --global alias.br 'branch'
git config --global alias.ca 'commit --amend'
git config --global alias.cc 'cherry-pick --continue'
git config --global alias.cf 'commit --amend --no-edit'
git config --global alias.cm 'commit'
git config --global alias.co 'checkout'
git config --global alias.cp 'cherry-pick'
git config --global alias.dc 'diff --cached'
git config --global alias.ln 'log --pretty=format:"%C(yellow)%h\\ %C(green)[%as]\\ %C(reset)%s%C(blue)\\ [%an]\\%C(red)%d" --decorate --numstat'
git config --global alias.ls 'log --pretty=format:"%C(yellow)%h\\ %C(green)[%as]\\ %C(reset)%s%C(blue)\\ [%an]\\%C(red)%d" --decorate'
git config --global alias.lt 'log -1 HEAD'
git config --global alias.pr 'pull --rebase'
git config --global alias.ra 'rebase --abort'
git config --global alias.rc 'rebase --continue'
git config --global alias.re 'rebase'
git config --global alias.ri 'rebase -i'
git config --global alias.sp 'stash pop'
git config --global alias.ss 'stash show -p stash@{0}'
git config --global alias.st 'status'
git config --global alias.su 'status -uno'
git config --global alias.us 'reset HEAD --'

git config --global alias.exp 'reflog expire --expire=now --expire-unreachable=now --all'
git config --global alias.gcp 'gc --prune=now'
git config --global alias.mod '"!f() { git diff --name-status \"$1^\" \"$1\"; }; f"'
git config --global alias.red 'rebase --committer-date-is-author-date'
git config --global alias.sup 'submodule update --init --recursive'
git config --global alias.til '"!f() { git log ${1}..HEAD; }; f"'
