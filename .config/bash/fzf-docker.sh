_fzf_wrapper() {
  fzf \
    --border-label-pos=2 \
    "$@"
}

_fzf_docker_check() {
  docker ps > /dev/null 2>&1
  return $?
}

_fzf_docker_images() {
  _fzf_docker_check || return
  docker images | sed 1d |
  _fzf_wrapper \
    --height 40% \
    --no-sort \
    --border-label '💿 Images' |
  awk 'image = $2=="<none>" ? $3 : $1":"$2 { print image }'
}

__fzf_docker_init() {
  local opt key
  for opt in "$@"; do
    key=${opt:0:1}
    bind -m emacs-standard '"\C-g\C-'"$key"'": " \C-u \C-a\C-k`_fzf_docker_'"$opt"'`\e\C-e\C-y\C-a\C-y\ey\C-h\C-e\er \C-h"'
    bind -m vi-command     '"\C-g\C-'"$key"'": "\C-z\C-g\C-'"$key"'\C-z"'
    bind -m vi-insert      '"\C-g\C-'"$key"'": "\C-z\C-g\C-'"$key"'\C-z"'
  done
}

__fzf_docker_init images
