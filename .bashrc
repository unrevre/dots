#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

declare -A __c=()
declare -A colours=([-]='0' [0]='38;5;6'  [1]='38;5;4'  [2]='38;5;5')
for i in "${!colours[@]}"; do
    declare "__c[$i]=$(printf '\033[%sm' "${colours[$i]}")"
done

export EDITOR="vim"
export PATH="$HOME/.local/bin:$PATH"

export AZCOPY_AUTO_LOGIN_TYPE=AZCLI
export FZF_DEFAULT_OPTS='--multi --layout reverse --height ~40% --border --color=info:2,border:3,spinner:4,hl:3,pointer:1,header:4,marker:11,prompt:11,hl+:1 --bind "ctrl-e:preview-down,ctrl-y:preview-up,ctrl-f:preview-page-down,ctrl-b:preview-page-up"'
export GCC_COLORS='error=38;5;1:warning=38;5;9:note=38;5;3:caret=38;5;2:locus=01:quote=01'
export LESS_TERMCAP_md=${__c[0]}
export LESS_TERMCAP_me=${__c[-]}
export LESS_TERMCAP_so=${__c[1]}
export LESS_TERMCAP_se=${__c[-]}
export LESS_TERMCAP_us=${__c[2]}
export LESS_TERMCAP_ue=${__c[-]}
export MOSH_ESCAPE_KEY=$'\x1F'
export PYENV_ROOT="$HOME/.pyenv"
export VIRTUAL_ENV_DISABLE_PROMPT=1

[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"

alias dots='git --git-dir=$HOME/.dots --work-tree=$HOME'
alias grep='grep --color=auto'
alias less='less -R'
alias ls='ls --color=auto'
alias open='xdg-open'

PS1="\[${__c[0]}\]┌─[\u@\h] \[${__c[1]}\]\W\[${__c[2]}\]\$(_get_git_branch)\n\
\[${__c[0]}\]└─╼ $\[${__c[-]}\]\$(_get_environment) "

HISTCONTROL=ignoredups
HISTFILESIZE=2048
HISTSIZE=1024

shopt -s histappend

stty -ixon

bind '"\C-k"':kill-line
bind '"\C-j"':backward-kill-line
bind '"\C-u"':kill-whole-line

bind '"\C-f"':shell-forward-word
bind '"\C-b"':shell-backward-word
bind '"\C-d"':shell-kill-word
bind '"\C-w"':shell-backward-kill-word
bind '"\M-f"':forward-word
bind '"\M-b"':backward-word
bind '"\M-d"':kill-word
bind '"\M-w"':backward-kill-word

eval "$(pyenv init -)"
eval "$(fzf --bash)"

# shellcheck source=/dev/null
for f in "${HOME}"/.config/bash/*.sh; do [[ -r "$f" ]] && . "$f"; done

completions=(
    /usr/share/bash-completion/completions/git
    /usr/share/bash-completion/completions/makepkg
    /usr/share/bash-completion/completions/mosh
    /usr/share/bash-completion/completions/pacman
    /usr/share/bash-completion/completions/pip
    /usr/share/bash-completion/completions/pyenv
)

# shellcheck source=/dev/null
for f in "${completions[@]}"; do [[ -r "$f" ]] && . "$f"; done

ap() {
    if [ -d "$1" ]; then
        (cd "$1" || return; pwd)
    elif [ -f "$1" ]; then
        if [[ $1 == /* ]]; then
            echo "$1"
        elif [[ $1 == */* ]]; then
            echo "$(cd "${1%/*}" || return; pwd)/${1##*/}"
        else
            echo "$(pwd)/$1"
        fi
    else
        echo "$1"
    fi
}

up() {
    if [[ $# -eq 0 || $1 -gt 0 ]]; then
        cd "$(eval printf '../'%.0s "{1..$1}")" && pwd;
    fi
}

fzd() {
    cat "$HOME"/.config/fzf/*.dict | while IFS=':' read -r key value; do
        echo -e "\033[38;5;3m${key}: \033[0m${value}"
    done | fzf -m --ansi | cut -d ' ' -f 2-
}

hat() {
    local count
    if [ "${1}" -eq "${1}" ] 2>/dev/null; then
        count="${1}"
        shift 1
    fi
    count="${count:-1}"

    mapfile -t
    printf -- '%s\n' "${MAPFILE[@]:0:count}" >&2
    printf -- '%s\n' "${MAPFILE[@]:count}"
}

# shellcheck disable=SC2016
bind '"\C-x\C-d": " \C-u \C-a\C-k`fzd`\e\C-e\C-y\C-a\C-y\ey\C-h\C-e\er\C-h"'

_get_git_branch() {
    local branch
    if git --version &> /dev/null; then
        # On branches, this will return the branch name
        # On non-branches, (no branch)
        branch="$(git symbolic-ref HEAD 2> /dev/null | sed -e 's/refs\/heads\///')"
        [[ "$branch" != "" ]] && echo " :$branch:"
    fi
}

_get_environment() {
    [[ -n "$VIRTUAL_ENV" ]] && echo " (${VIRTUAL_ENV##*/})"
}

_expand_cursor_word() {
    local line word full before after

    line="${READLINE_LINE:0:$READLINE_POINT}"
    word="${line##* }"
    full=$($1 "${word}")

    before="${READLINE_LINE:0:$((READLINE_POINT - ${#word}))}"
    after="${READLINE_LINE:$READLINE_POINT}"

    READLINE_LINE="${before}${full}${after}"
    ((READLINE_POINT += ${#full} - ${#word}))
}

_as_github_url() {
    echo -n "git@github.com:${1}.git"
}

bind -x '"\C-x\C-a":"_expand_cursor_word ap;"'
bind -x '"\C-x\C-g":"_expand_cursor_word _as_github_url;"'
