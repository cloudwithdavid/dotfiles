# ~/.bashrc: executed by bash(1) for non-login shells.

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# 1. INTERACTIVE GUARD
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case $- in
    *i*) ;;
      *) return;;
esac

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# 2. SHELL OPTIONS & HISTORY MANAGEMENT
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# History retention
HISTSIZE=10000
HISTFILESIZE=20000

# Control history behavior
HISTCONTROL=ignoreboth:erasedups
HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S  "

# Shell behavior options
shopt -s histappend               # Append to history instead of overwriting
shopt -s cmdhist                  # Save multi-line commands as single entry
shopt -s checkwinsize             # Update window size after each command
shopt -s autocd 2>/dev/null       # Enter directory by typing path alone

# Save commands immediately and sync across open terminal sessions
PROMPT_COMMAND='history -a; history -n'

# Readline options (tab completion behavior)
bind "set completion-ignore-case on"
bind "set show-all-if-ambiguous on"

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# 3. ALIASES & VARIABLES
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Navigation & System
alias rc='source ~/.bashrc'
alias cl='clear'
alias cdp='cd -P'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Archive Operations
alias tarc='tar -czvf'  # Usage: tarc archive.tgz /path/to/folder # Create archive
alias tarx='tar -xvf'   # Usage: tarx archive.tgz # Extract archive

# Project paths
projects="$HOME/wsl-projects"
brc="$projects/git/dotfiles/bash/.bashrc"

site="$projects/git/cwd-site"
sitedemo="$projects/git/cwd-site-demo"
llmconfig="$projects/git/llm-config"
awsrestart="$projects/git/aws-restart"
restartlabs="$projects/aws-restart-labs"


# File Listing & Colors
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias ll='ls -lFh'
alias lla='la -AFlh'
alias la='ls -A'      
alias l='ls -CF'      

# Git
alias gs='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gf='git fetch'
alias gb='git branch'
alias gsw='git switch'
alias gco='git checkout'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --oneline --graph --decorate'
alias gr='git remote -v'

# External Alias File (if used)
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# 4. COMPLETION & TOOLS (FZF, ZOXIDE)
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Standard Bash Completion
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Lesspipe for non-text inputs
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# FZF Configuration & Integrations
if command -v fzf >/dev/null 2>&1; then
    # Modern inline layout with border
    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
    
    # Load system keybindings and completions
    [ -f /usr/share/doc/fzf/examples/key-bindings.bash ] && source /usr/share/doc/fzf/examples/key-bindings.bash
    [ -f /usr/share/doc/fzf/examples/completion.bash ] && source /usr/share/doc/fzf/examples/completion.bash
fi

# Zoxide Initialization (Smarter 'cd')
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init bash)"
fi

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# 5. PS1: GIT-AWARE PROMPT CONFIGURATION
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if [ -f /usr/lib/git-core/git-sh-prompt ]; then
    source /usr/lib/git-core/git-sh-prompt
elif [ -f /usr/share/git-core/contrib/completion/git-prompt.sh ]; then
    source /usr/share/git-core/contrib/completion/git-prompt.sh
fi

export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM="verbose"

# Streamlined PS1 using built-in __git_ps1 formatting
if declare -F __git_ps1 >/dev/null; then
    PROMPT_COMMAND='__git_ps1 "\[\e[94m\]\W" "\[\e[97m\]\$ " " \[\e[96m\](\[\e[38;5;49m\]%s\[\e[96m\])"'
else
    PS1='\[\e[94m\]\W\[\e[97m\]\$ '
fi

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# 6. HELPER FUNCTIONS
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
envnames() {
    env | cut -d= -f1
}

# Open files in CudaText from WSL
cuda() {
    if [ -z "$1" ]; then
        ("/mnt/c/cudatext/cudatext.exe" >/dev/null 2>&1 &)
    else
        ("/mnt/c/cudatext/cudatext.exe" "$(wslpath -w "$1")" >/dev/null 2>&1 &)
    fi
}

# Open a file or directory in Windows
open() {
    explorer.exe "$(wslpath -aw "${1:-.}")"
}

# Reveal a file or directory in Windows File Explorer
show() {
    local target="${1:-.}" winpath

    if (( $# > 1 )); then
        printf 'Usage: reveal [path]\n' >&2
        return 2
    fi

    if [[ ! -e "$target" && ! -L "$target" ]]; then
        printf 'Not found: %s\n' "$target" >&2
        return 1
    fi

    target=$(realpath -s -- "$target") || return
    winpath=$(wslpath -w "$target") || return

    explorer.exe /select, "$winpath"
}

# Make a directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Start_ssh_agent
sshagent() {
    if ! pgrep -u "$USER" ssh-agent >/dev/null 2>&1; then
        eval "$(ssh-agent -s)" >/dev/null
    fi
}

