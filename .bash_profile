#
# ~/.bash_profile
#

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"

[ -r ~/.bashrc ] && . ~/.bashrc
