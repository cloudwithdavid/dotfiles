#!/usr/bin/env bash

set -e

echo "==> Updating packages..."
sudo apt update

echo "==> Installing shell tools..."
sudo apt install -y \
    git \
    bash-completion \
    fzf \
    zoxide

echo "==> Creating local bin directory..."
mkdir -p "$HOME/.local/bin"

BASHRC="$HOME/.bashrc"

echo "==> Backing up existing .bashrc..."
cp "$BASHRC" "$BASHRC.backup"

# Remove a previous version of THIS managed block if it exists.
sed -i \
    '/# >>> DOTFILES WSL BASH SETUP >>>/,/# <<< DOTFILES WSL BASH SETUP <<</d' \
    "$BASHRC"

echo "==> Adding WSL Bash configuration..."

cat >> "$BASHRC" <<'EOF'

# >>> DOTFILES WSL BASH SETUP >>>

# ============================================================
# WSL BASH SETUP
# ============================================================


# ------------------------------------------------------------
# 1. PATH
# ------------------------------------------------------------

# User-installed scripts and commands
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
esac


# ------------------------------------------------------------
# 2. COMMAND HISTORY
# ------------------------------------------------------------

HISTSIZE=10000
HISTFILESIZE=20000

shopt -s histappend
shopt -s cmdhist

HISTCONTROL=ignoreboth:erasedups
HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S  "


# ------------------------------------------------------------
# 3. FILE / DIRECTORY ALIASES
# ------------------------------------------------------------

alias ll='ls -alFh'
alias la='ls -A'
alias l='ls -CF'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias c='clear'


# ------------------------------------------------------------
# 4. GIT ALIASES
# ------------------------------------------------------------

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


# ------------------------------------------------------------
# 5. BASH COMPLETION
# ------------------------------------------------------------

if [ -f /usr/share/bash-completion/bash_completion ]; then
    source /usr/share/bash-completion/bash_completion
fi


# ------------------------------------------------------------
# 6. GIT-AWARE PROMPT
# ------------------------------------------------------------

if [ -f /usr/lib/git-core/git-sh-prompt ]; then
    source /usr/lib/git-core/git-sh-prompt
elif [ -f /usr/share/git-core/contrib/completion/git-prompt.sh ]; then
    source /usr/share/git-core/contrib/completion/git-prompt.sh
fi

export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM="verbose"

# Git repo:
# aws-restart (main|u=)$
#
# Non-Git directory:
# git$
#
# Current directory only.
# Git parentheses appear only inside a Git repository.

if declare -F __git_ps1 >/dev/null; then
    PS1='\[\e[94m\]\W\[\e[96m\]$(git rev-parse --is-inside-work-tree >/dev/null 2>&1 && printf " (")\[\e[38;5;49m\]$(__git_ps1 "%s")\[\e[96m\]$(git rev-parse --is-inside-work-tree >/dev/null 2>&1 && printf ")")\[\e[97m\]\$ '
else
    PS1='\[\e[94m\]\W\[\e[97m\]\$ '
fi


# ------------------------------------------------------------
# 7. HISTORY SYNC BETWEEN TERMINALS
# ------------------------------------------------------------

PROMPT_COMMAND='history -a; history -n'


# ------------------------------------------------------------
# 8. FZF
# ------------------------------------------------------------

# Ctrl+R fuzzy command-history search
if [ -f /usr/share/doc/fzf/examples/key-bindings.bash ]; then
    source /usr/share/doc/fzf/examples/key-bindings.bash
fi

# Fuzzy completion
if [ -f /usr/share/doc/fzf/examples/completion.bash ]; then
    source /usr/share/doc/fzf/examples/completion.bash
fi


# ------------------------------------------------------------
# 9. ZOXIDE
# ------------------------------------------------------------

if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init bash)"
fi


# ------------------------------------------------------------
# 10. SSH AGENT
# ------------------------------------------------------------

start_ssh_agent() {
    if ! pgrep -u "$USER" ssh-agent >/dev/null 2>&1; then
        eval "$(ssh-agent -s)" >/dev/null
    fi
}

# Enable if desired:
# start_ssh_agent


# ------------------------------------------------------------
# 11. GENERAL SHELL QUALITY OF LIFE
# ------------------------------------------------------------

shopt -s autocd 2>/dev/null
shopt -s checkwinsize

bind "set completion-ignore-case on"
bind "set show-all-if-ambiguous on"

# <<< DOTFILES WSL BASH SETUP <<<
EOF

echo
echo "==> WSL Bash environment configured."
echo "==> Original .bashrc backed up to:"
echo "    $HOME/.bashrc.backup"
echo
echo "Run:"
echo "    source ~/.bashrc"
echo
echo "Setup complete."
