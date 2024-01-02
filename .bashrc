#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PATH="/usr/local/opt/coreutils/libexec/gnubin:/usr/local/sbin:$PATH"
MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"

export ARCHFLAGS="-arch x86_64"
export SDKROOT="/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"
export VIRTUAL_ENV_DISABLE_PROMPT=1

export LESS_TERMCAP_md=$'\e[01;34m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;31m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_us=$'\e[01;32m'
export LESS_TERMCAP_ue=$'\e[0m'

export HOMEBREW_MIRROR_URL="https://mirrors.tuna.tsinghua.edu.cn"
export HOMEBREW_API_DOMAIN="$HOMEBREW_MIRROR_URL/homebrew-bottles/api"
export HOMEBREW_BOTTLE_DOMAIN="$HOMEBREW_MIRROR_URL/homebrew-bottles"
export HOMEBREW_BREW_GIT_REMOTE="$HOMEBREW_MIRROR_URL/git/homebrew/brew.git"
export HOMEBREW_CORE_GIT_REMOTE="$HOMEBREW_MIRROR_URL/git/homebrew/homebrew-core.git"

PS1="\[\033[38;5;4m\]┌─[\u@\h] \[\033[38;5;2m\]\W\[\033[38;5;3m\]\$(get_git_branch)\n\
\[\033[38;5;4m\]└─╼ $\[\033[0m\]\$(get_virtualenv) "

alias brew='env PATH=${PATH//$(pyenv root)\/shims:/} brew'
alias dots='git --git-dir=$HOME/.dots/ --work-tree=$HOME'
alias grep='grep --color=auto'
alias ls='ls --color=auto'

HISTCONTROL=ignoredups

stty -ixon

bind '"\C-f"':shell-forward-word
bind '"\C-b"':shell-backward-word
bind '"\C-d"':shell-kill-word

completions=(
    /usr/local/etc/bash_completion.d/brew
    /usr/local/etc/bash_completion.d/brew-services
    /usr/local/etc/bash_completion.d/git-completion.bash
    /usr/local/etc/bash_completion.d/git-prompt.sh
)

for f in "${completions[@]}"; do [[ -r "$f" ]] && . "$f"; done

function up() {
    if [[ $# -eq 0 || $1 -gt 0 ]]; then
        cd $(eval printf '../'%.0s {1..$1}) && pwd;
    fi
}

function get_git_branch() {
    if git --version &> /dev/null; then
        # On branches, this will return the branch name
        # On non-branches, (no branch)
        ref="$(git symbolic-ref HEAD 2> /dev/null | sed -e 's/refs\/heads\///')"
        [[ "$ref" != "" ]] && echo " :$ref:"
    fi
}

function get_virtualenv() {
    [[ -n "$VIRTUAL_ENV" ]] && echo " (${VIRTUAL_ENV##*/})"
}
