if command -v exa &>/dev/null; then
    alias ls="exa --icons --group-directories-first"
    alias ll="exa -l -g --icons --group-directories-first"
    alias lla="ll -a"
    alias tree="exa -T --icons"
else
    if [[ "$(uname -s | awk '{print tolower($1)}')" = darwin* ]]; then
        alias ls="gls --color -h --group-directories-first"
        alias ll="gls --color -l -h --group-directories-first"
        alias lla="ll -a"
    else
        alias ls="ls --color -h --group-directories-first"
        alias ll="ls --color -l -h --group-directories-first"
        alias lla="ll -a"
    fi
fi

if command -v fd-find &>/dev/null; then
    alias fd=fdfind
fi

# check Terminal support color24 bit
alias color24bit="curl -s https://raw.githubusercontent.com/JohnMorales/dotfiles/master/colors/24-bit-color.sh | bash"
# find my ip address
alias myip="curl http://ipecho.net/plain; echo"
# git pull multiple
alias multipull="find . -mindepth 1 -maxdepth 1 -type d -print -exec git -C {} pull \;"
# search running processes. Usage: psg <process_name>
alias psg="ps aux $([[ -n "$(uname -a | grep CYGWIN)" ]] && echo '-W') | grep -i $1"

alias zs="source $HOME/.zshrc"

# open
alias mate="open -a TextMate"
alias excel="open -a Microsoft\ Excel"
alias word="open -a Microsoft\ Word"

if command -v docker-compose &>/dev/null; then
    alias dc='docker-compose'
    alias dcd='docker-compose down'
    alias dcl='docker-compose logs -f'
    alias dcr='docker-compose run --rm'
    alias dcre='docker-compose down && docker-compose up -d && docker-compose logs -f'
    alias dcu='docker-compose up -d'
    alias dcuf='docker-compose up -d --force-recreate'
    alias dcul='docker-compose up -d && docker-compose logs -f'
    alias dprune='docker ps -aq --no-trunc -f status=exited | xargs docker rm'
    alias dps='docker ps -a | less -S'
    alias docker-clean=' \
    docker container prune -f ; \
    docker image prune -f ; \
    docker network prune -f ; \
    docker volume prune -f '
fi

##### vim
# use `\vim` or `command vim` to get the real vim.
if command -v nvim &>/dev/null; then
    alias vim=nvim
fi

###### global aliases
# (work at any position within the command line)
alias -g M="|more"
alias -g G="|grep"
alias -g L="|less"
alias -g W="|wc -l"
alias -g P="|peco"
alias -g H="|head"
alias -g C="|pbcopy"

###### suffix aliases
# (eg. "foo.md" to open Markdown files in nvim)
# alias -s md=nvim
# alias -s sh=nvim
# alias -s py=nvim
# alias -s vim=nvim
# alias -s lua=nvim
# alias -s txt=nvim
# alias -s log=nvim
# alias -s ini=nvim
# alias -s yml=nvim
# alias -s yaml=nvim
# alias -s toml=nvim
