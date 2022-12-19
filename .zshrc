typeset -A __CONFIG
__CONFIG[ITALIC_ON]=$'\e[3m'
__CONFIG[ITALIC_OFF]=$'\e[23m'

autoload -U compinit
compinit -u
zstyle ':completion:*' matcher-list '' '+m:{[:lower:]}={[:upper:]}' '+m:{[:upper:]}={[:lower:]}' '+m:{_-}={-_}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors ''
zstyle -e ':completion:*' special-dirs '[[ $PREFIX = (../)#(..) ]] && reply=(..)'
zstyle ':completion:*:complete:(cd|pushd):*' tag-order 'local-directories named-directories'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format %F{default}%B%{$__CONFIG[ITALIC_ON]%}%F{cyan}----- %d -----%{$__CONFIG[ITALIC_OFF]%}%b%f
zstyle ':completion:*' menu select

# setopt AUTO_CD                 # [default] .. is shortcut for cd .. (etc)
setopt AUTO_PARAM_SLASH        # tab completing directory appends a slash
setopt AUTO_PUSHD              # [default] cd automatically pushes old dir onto dir stack
setopt AUTO_RESUME             # allow simple commands to resume backgrounded jobs
setopt CLOBBER                 # allow clobbering with >, no need to use >!
# setopt CORRECT                 # [default] command auto-correction
# setopt CORRECT_ALL             # [default] argument auto-correction
setopt NO_FLOW_CONTROL         # disable start (C-s) and stop (C-q) characters
setopt HIST_IGNORE_ALL_DUPS    # filter non-contiguous duplicates from history
setopt HIST_FIND_NO_DUPS       # don't show dupes when searching
setopt HIST_IGNORE_DUPS        # do filter contiguous duplicates from history
setopt HIST_IGNORE_SPACE       # [default] don't record commands starting with a space
setopt HIST_VERIFY             # confirm history expansion (!$, !!, !foo)
# setopt IGNORE_EOF              # [default] prevent accidental C-d from exiting shell
setopt INTERACTIVE_COMMENTS    # [default] allow comments, even in interactive shells
setopt LIST_PACKED             # make completion lists more densely packed
setopt MENU_COMPLETE           # auto-insert first possible ambiguous completion
setopt NO_NOMATCH              # [default] unmatched patterns are left unchanged
# setopt PRINT_EXIT_VALUE        # [default] for non-zero exit status
setopt PUSHD_IGNORE_DUPS       # don't push multiple copies of same dir onto stack
setopt PUSHD_SILENT            # [default] don't print dir stack after pushing/popping
setopt SHARE_HISTORY           # share history across shells

autoload -U select-word-style
select-word-style bash
source ~/.zsh.plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh.plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
source ~/.zsh.plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs
zstyle ':completion:*:*:cdr:*:*' menu selection
zstyle ':chpwd:*' recent-dirs-default true

bindkey -e
bindkey \^U backward-kill-line
bindkey "^[[1~" beginning-of-line
bindkey "^[[4~" end-of-line
bindkey "^[[3~" delete-char

if tput cbt &> /dev/null; then
  bindkey "$(tput cbt)" reverse-menu-complete
fi

export VISUAL=nvim
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^x^x' edit-command-line

source $HOME/.zsh/aliases.zsh
source $HOME/.zsh/functions.zsh
source $(brew --prefix)/opt/spaceship/spaceship.zsh

if command -v fzf &>/dev/null; then
  source $HOME/.zsh/fzf.zsh
fi

if [ -f ${HOME}/.zshrc.local ]; then
  source ${HOME}/.zshrc.local
fi

if [[ $TERM == "dumb" ]]; then # in emacs
  PS1='%(?..[%?])%!:%~%# '
  unsetopt zle
  unsetopt prompt_cr
  unsetopt prompt_subst
  unfunction precmd
  unfunction preexec
# else
#   echo "oops..."
fi

autoload -U add-zsh-hook
function -set-tab-and-window-title() {
  emulate -L zsh
  local CMD="${1:gs/$/\\$}"
  print -Pn "\e]0;$CMD:q\a"
}

HISTCMD_LOCAL=0

function -update-window-title-precmd() {
  emulate -L zsh
  if [[ HISTCMD_LOCAL -eq 0 ]]; then
    -set-tab-and-window-title "$(basename $PWD)"
  else
    local LAST=$(history | tail -1 | awk '{print $2}')
    if [ -n "$TMUX" ]; then
      -set-tab-and-window-title "$LAST"
    else
      -set-tab-and-window-title "$(basename $PWD) > $LAST"
    fi
  fi
}
add-zsh-hook precmd -update-window-title-precmd

function -update-window-title-preexec() {
  emulate -L zsh
  setopt EXTENDED_GLOB
  HISTCMD_LOCAL=$((++HISTCMD_LOCAL))
  local TRIMMED="${2[(wr)^(*=*|mosh|ssh|sudo)]}"
  if [ -n "$TMUX" ]; then
    -set-tab-and-window-title "$TRIMMED"
  else
    -set-tab-and-window-title "$(basename $PWD) > $TRIMMED"
  fi
}
add-zsh-hook preexec -update-window-title-preexec

if [ -d ${HOME}/.cabal/bin ]; then
  export PATH="${HOME}/.cabal/bin:$PATH"
fi

export PATH=$HOME/bin:$PATH
export EDITOR="emacsclient"
export ALTERNATE_EDITOR=""

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" --no-use # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
