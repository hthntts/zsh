export BAT_THEME="OneHalfDark"
export FZF_DEFAULT_COMMAND="fd --hidden --follow --exclude '.git' --exclude 'node_modules' --exclude '__pycache__' --exclude '.dropbox.cache'"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND --type d"
export FZF_DEFAULT_OPTS="
--layout=reverse
--info=inline
--color=hl:#8CDE5A
--color=hl+:#8CDE5A
--color='prompt:#d7005f'
--preview-window=:hidden,border-sharp
--preview '(bat --style=numbers --color=always {} ||  highlight -O ansi -l {} || coderay {} || rougify {} || cat {}) 2> /dev/null | head -200'
--pointer='ᐅ'
--marker='✓'
--bind 'ctrl-q:abort'
--bind '?:toggle-preview'
--bind 'ctrl-e:execute(echo {+} | xargs nvim)'
--bind 'ctrl-c:execute-silent(echo {+} | pbcopy)'
--header '?: Toggle Preview
ctrl-q: Abort
ctrl-c: Copy to Clipboard'"

alias v="fd --type f | fzf-tmux -p 80% -m --prompt='  Fuzzy Finder > ' --reverse | xargs nvim"
alias -g F="| fzf-tmux -p 80% -m --prompt='  Fuzzy Finder > '"

# [v]irtual[env] ---------------------------------------------------------------
function venv() {
  mkdir -p $HOME/.venv
  local selected_env
  selected_env=$(command ls ~/.venv/ | fzf-tmux -p 80% --prompt='  Fuzzy Finder > ' --header 'Choose Python Virtualenv')
  if [ -n "$selected_env" ]; then
    source "$HOME/.venv/$selected_env/bin/activate"
  fi
}

# auto [c][d] from [b]ookmark --------------------------------------------------
function cdb() {
  local dest_dir=$(cat ~/.cdg | sort | fzf-tmux -p 80% --prompt='  Fuzzy Finder > ' --header='Choose Bookmarks (Folder)')
  if [[ $dest_dir != '' ]]; then
    cd "$dest_dir"
  fi
}

# [m]icrosoft [e]dge [h]istory -------------------------------------------------
function meh() {
  local cols sep
  cols=$(( COLUMNS / 3 ))
  sep='{::}'
  cp -f ~/Library/Application\ Support/Microsoft\ Edge/Default/History /tmp/h
  sqlite3 -separator $sep /tmp/h \
    "select substr(title, 1, $cols), url
      from urls order by last_visit_time desc" |
  awk -F $sep '{printf "%-'$cols's  \x1b[36m%s\x1b[m\n", $1, $2}' |
  fzf-tmux -p 80% -m --prompt='  Fuzzy Finder > ' --header='Choose history (Microsoft Edge)' --ansi --multi | sed 's#.*\(https*://\)#\1#' | xargs open
}

# [tmux] [j]ump ----------------------------------------------------------------
function tmuxj() {
  local session
  session=$(tmux list-session | fzf-tmux -p 80% --prompt='  Fuzzy Finder > ' --header='Choose Tmux Session' | awk -F: '{print $1}')
  if [[ ! -z ${TMUX} ]]; then
    tmux switch-client -t $session
  else
    tmux a -t $session
  fi
}

# [git] [delete] [branches]-----------------------------------------------------
function git-delete-branches() {
  local branches_to_delete
  branches_to_delete=$(git branch | fzf --multi)

  if [ -n "$branches_to_delete" ]; then
    git branch --delete --force $branches_to_delete
  fi
}

# ------------------------------------------------------------------------------
function cd-fzf-ghqlist() {
  local GHQ_ROOT=`ghq root`
  local REPO=`ghq list -p | sed -e 's;'${GHQ_ROOT}/';;g' | fzf-tmux -p 80% --prompt='  Fuzzy Finder > ' --header='Choose Project'`
  if [ -n "${REPO}" ]; then
    BUFFER="cd ${GHQ_ROOT}/${REPO}"
  fi
  zle accept-line
}
zle -N cd-fzf-ghqlist
bindkey '^G' cd-fzf-ghqlist

# ------------------------------------------------------------------------------
function fzf-history-buffer() {
  local HISTORY=$(history -n -r 1 | fzf-tmux -p 80% --prompt='  Fuzzy Finder > ' --header='Choose History Command Line' +m)
  BUFFER=$HISTORY
  if [ -n "$HISTORY" ]; then
    CURSOR=$#BUFFER
  else
    zle accept-line
  fi
}
zle -N fzf-history-buffer
bindkey '^R' fzf-history-buffer

# ------------------------------------------------------------------------------
function fzf-sshconfig-ssh() {
  local SSH_HOST=$(awk '
      tolower($1)=="host" {
          for (i=2; i<=NF; i++) {
              if ($i !~ "[*?]") {
                  print $i
              }
          }
      }
  ' ~/.ssh/config | sort | fzf-tmux -p 80% --prompt='  Fuzzy Finder > ' --header='Choose Server SSH' +m)
  if [ -n "$SSH_HOST" ]; then
    BUFFER="ssh $SSH_HOST"
  fi
  zle accept-line
}
zle -N fzf-sshconfig-ssh
bindkey '^\' fzf-sshconfig-ssh

# ------------------------------------------------------------------------------
FILE=$HOME/.ssh/tux
if [[ -f "$FILE" ]]; then
    bindkey -s '^]' 'sh $FILE $TUXCODE^M'
else
    bindkey -r '^]'
fi
