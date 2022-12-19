# [ag] the_silver_searcher -----------------------------------------------------
function ag() {
  emulate -L zsh
  command ag --hidden --pager="less -iFMRSX" --color-path=34\;3 --color-line-number=35 --color-match=35\;1\;4 "$@"
}

# [git] ------------------------------------------------------------------------
function git() {
  if [ $# -eq 0 ]; then
    command git status
  elif [ "$1" = root ]; then
    shift
    local ROOT
    if [ "$(command git rev-parse --is-inside-git-dir 2> /dev/null)" = true ]; then
      if [ "$(command git rev-parse --is-bare-repository)" = true ]; then
        ROOT="$(command git rev-parse --absolute-git-dir)"
      else
        ROOT="$(command git rev-parse --git-dir)/.."
      fi
    else
      # Git 2.13.0 and above:
      ROOT="$(command git rev-parse --show-superproject-working-tree 2> /dev/null)"
      if [ -z "$ROOT" ]; then
        ROOT="$(command git rev-parse --show-toplevel 2> /dev/null)"
      fi
    fi
    if [ -z "$ROOT" ]; then
      ROOT="$PWD"
    fi
    if [ $# -eq 0 ]; then
      if [ -t 1 ]; then
        cd "$ROOT"
      else
        echo "$ROOT"
      fi
    else
      (cd "$ROOT" && eval "$@")
    fi
  else
    command git "$@"
  fi
}

# [headers] information --------------------------------------------------------
function headers() {
  emulate -L zsh
  if [ $# -ne 1 ]; then
    echo "error: a host argument is required"
    return 1
  fi
  local REMOTE=$1
  curl -sSL -D - "$REMOTE" -o /dev/null
}

# [scratch] shell --------------------------------------------------------------
function scratch() {
  local SCRATCH=$(mktemp -d)
  echo 'Spawing subshell in scratch directory:'
  echo "  $SCRATCH"
  (cd $SCRATCH; zsh)
  echo "Removing scratch directory"
  rm -rf "$SCRATCH"
}

# [ssl] information ------------------------------------------------------------
function ssl() {
  emulate -L zsh
  if [ $# -ne 1 ]; then
    echo "error: a host argument is required"
    return 1
  fi
  local REMOTE=$1
  echo | openssl s_client -showcerts -servername "$REMOTE" -connect "$REMOTE:443" 2>/dev/null | openssl x509 -inform pem -noout -text
}

# [reg]ex and [m]o[v]e ---------------------------------------------------------
function regmv() {
  emulate -L zsh

  if [ $# -lt 2 ]; then
    echo "  Usage: regmv 'regex' file(s)"
    echo "  Where:       'regex' should be of the format '/find/replace/'"
    echo "Example: regmv '/\.tif\$/.tiff/' *"
    echo "   Note: Must quote/escape the regex otherwise \"\.\" becomes \".\""
    return 1
  fi
  local REGEX="$1"
  shift
  while [ -n "$1" ]
  do
    local NEWNAME=$(echo "$1" | sed "s${REGEX}g")
    if [ "${NEWNAME}" != "$1" ]; then
      mv -i -v "$1" "$NEWNAME"
    fi
    shift
  done
}

# [cat] [f]ile to [o]ne [l]ine -------------------------------------------------
function catfol() {
  cat $1 | tr -d "\n"
}

# [v]irtual[env] [auto] --------------------------------------------------------
function venv_auto() {
  if [ -f $HOME/.venv/$1/bin/activate ]
  then
    source $HOME/.venv/$1/bin/activate
  else
    if [ -f $HOME/.venv/$1/bin/activate ]
    then
      source $HOME/.venv/$1/bin/activate
    else
      pip3 install virtualenv
      virtualenv $HOME/.venv/$1
      $HOME/.venv/$1/bin/python -m pip install -U pip
      source $HOME/.venv/$1/bin/activate
    fi
  fi
}

# [pip] ------------------------------------------------------------------------
function pip-upgrade() {
  python -m pip install -U $(python -m pip list --outdated | tail -n +3 | awk '{print $1}')
}

function pip3-upgrade() {
  python3 -m pip3 install -U $(python3 -m pip3 list --outdated | tail -n +3 | awk '{print $1}')
}

function pip-remove() {
  pip uninstall -y -r <(pip freeze)
}

function pip3-remove() {
  pip3 uninstall -y -r <(pip3 freeze)
}

# repeat [until] it [success] --------------------------------------------------
function until-success() {
  "$@"
  while [ $? -ne 0 ]; do
    "$@"
  done
}

# repeat [until] it [error] ----------------------------------------------------
function until-error() {
  "$@"
  while [ $? -eq 0 ]; do
    "$@"
  done
}

# [port] [kill] ----------------------------------------------------------------
function port-kill() {
  lsof -i :$1 | tail -n +2 | awk '{ print $2 }' | xargs kill
}

# auto [c][d] from [b]ookmark [add] --------------------------------------------
function cdb-add () {
  local curr_dir="${PWD}"
  if ! grep -Fxq "$curr_dir" ~/.cdg; then
    echo "$curr_dir" >> ~/.cdg
  fi
}

# [tmux] session [c]reate ------------------------------------------------------
function tmuxc() {
  local session
  session=${${1:-$(pwd)}//./-}
  tmux list-sessions | cut -d":" -f1 | grep -e "^$session\$" > /dev/null
  if [[ $? != 0 ]]; then
    tmux new-session -d -c $(pwd) -s $session
  fi
  tmux switch-client -t $session
}

# [extract] --------------------------------------------------------------------
function extract() {
  local remove_archive
  local success
  local extract_dir

  if (( $# == 0 )); then
    cat <<-'EOF' >&2
      Usage: extract [-option] [file ...]
      Options:
          -r, --remove    Remove archive after unpacking.
		EOF
  fi

  remove_archive=1
  if [[ "$1" == "-r" ]] || [[ "$1" == "--remove" ]]; then
    remove_archive=0
    shift
  fi

  while (( $# > 0 )); do
    if [[ ! -f "$1" ]]; then
      echo "extract: '$1' is not a valid file" >&2
      shift
      continue
    fi

    success=0
    extract_dir="${1:t:r}"
    case "${1:l}" in
      (*.tar.gz|*.tgz) (( $+commands[pigz] )) && { pigz -dc "$1" | tar xv } || tar zxvf "$1" ;;
      (*.tar.bz2|*.tbz|*.tbz2) tar xvjf "$1" ;;
      (*.tar.xz|*.txz)
        tar --xz --help &> /dev/null \
        && tar --xz -xvf "$1" \
        || xzcat "$1" | tar xvf - ;;
      (*.tar.zma|*.tlz)
        tar --lzma --help &> /dev/null \
        && tar --lzma -xvf "$1" \
        || lzcat "$1" | tar xvf - ;;
      (*.tar.zst|*.tzst)
        tar --zstd --help &> /dev/null \
        && tar --zstd -xvf "$1" \
        || zstdcat "$1" | tar xvf - ;;
      (*.tar) tar xvf "$1" ;;
      (*.tar.lz) (( $+commands[lzip] )) && tar xvf "$1" ;;
      (*.gz) (( $+commands[pigz] )) && pigz -dk "$1" || gunzip -k "$1" ;;
      (*.bz2) bunzip2 "$1" ;;
      (*.xz) unxz "$1" ;;
      (*.lzma) unlzma "$1" ;;
      (*.z) uncompress "$1" ;;
      (*.zip|*.war|*.jar|*.sublime-package|*.ipsw|*.xpi|*.apk|*.aar|*.whl) unzip "$1" -d $extract_dir ;;
      (*.rar) unrar x -ad "$1" ;;
      (*.rpm) mkdir "$extract_dir" && cd "$extract_dir" && rpm2cpio "../$1" | cpio --quiet -id && cd .. ;;
      (*.7z) 7za x "$1" ;;
      (*.deb)
        mkdir -p "$extract_dir/control"
        mkdir -p "$extract_dir/data"
        cd "$extract_dir"; ar vx "../${1}" > /dev/null
        cd control; tar xzvf ../control.tar.gz
        cd ../data; extract ../data.tar.*
        cd ..; rm *.tar.* debian-binary
        cd ..
      ;;
      (*.zst) unzstd "$1" ;;
      (*)
        echo "extract: '$1' cannot be extracted" >&2
        success=1
      ;;
    esac
    (( success = $success > 0 ? $success : $? ))
    (( $success == 0 )) && (( $remove_archive == 0 )) && rm "$1"
    shift
  done
}

# ------------------------------------------------------------------------------
function -auto-ls-after-cd() {
  emulate -L zsh
  if [ "$ZSH_EVAL_CONTEXT" = "toplevel:shfunc" ]; then
    if ! [ -x "$(command -v exa)" ]; then
      ls --color -h --group-directories-first
    else
      exa -l -g --icons --group-directories-first
    fi
  fi
}
add-zsh-hook chpwd -auto-ls-after-cd
