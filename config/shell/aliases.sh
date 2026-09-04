#!/usr/bin/env bash
# Aliases — sourced by config/shell/bashrc.sh
# shellcheck shell=bash

# --- core -------------------------------------------------------------------
alias x='exit'                       # x = quit the shell
alias cl='clear'
alias c='clear'
alias q='exit'
alias h='history'
alias reload='source ~/.bashrc'
alias path='echo -e "${PATH//:/\\n}"'

# --- listing ----------------------------------------------------------------
if ls --color=auto >/dev/null 2>&1; then
  alias ls='ls --color=auto'
else
  alias ls='ls -G'                   # BSD/macOS
fi
alias ll='ls -alFh'
alias la='ls -A'
alias l='ls -CF'
alias lt='ls -alFht'                 # newest first
alias lsd='ls -d */'                 # directories only

# --- moving around ----------------------------------------------------------
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias -- -='cd -'                    # jump back to the previous directory
alias ~='cd ~'
alias dl='cd ~/Downloads'
alias dt='cd ~/Desktop'
alias labs='cd ~/labs'
alias md='mkdir -pv'

# --- grep / search ----------------------------------------------------------
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# --- safety nets ------------------------------------------------------------
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -I'                     # prompt once for 3+ files, not per file
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ports='ss -tulpn 2>/dev/null || netstat -tulpn'

# --- git --------------------------------------------------------------------
alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gaa='git add -A'
alias gc='git commit -v'
alias gcm='git commit -m'
alias gca='git commit -v --amend'
alias gco='git checkout'
alias gsw='git switch'
alias gb='git branch'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --oneline --graph --decorate -20'
alias gll='git log --oneline --graph --decorate --all'
alias gp='git push'
alias gpl='git pull'
alias gf='git fetch --all --prune'
alias gst='git stash'
alias gstp='git stash pop'

# --- dev --------------------------------------------------------------------
alias py='python3'
alias pip='pip3'
alias venv='python3 -m venv .venv && source .venv/bin/activate'
alias act='source .venv/bin/activate'
alias serve='python3 -m http.server'
alias n='npm'
alias nr='npm run'
alias ni='npm install'
alias p='pnpm'
alias pr='pnpm run'
alias d='docker'
alias dc='docker compose'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias k='kubectl'

command -v flyctl  >/dev/null 2>&1 && alias fly='flyctl'
command -v nvim    >/dev/null 2>&1 && alias vim='nvim' && alias v='nvim'
command -v bat     >/dev/null 2>&1 && alias cat='bat --paging=never'
command -v batcat  >/dev/null 2>&1 && alias bat='batcat'

# --- desktop / machine-specific (only if the tool is installed) -------------
command -v cursor >/dev/null 2>&1 && alias cursor='cursor --no-sandbox'
command -v flatpak >/dev/null 2>&1 && alias pinta='flatpak run com.github.PintaProject.Pinta'
[ -x "$HOME/.local/bin/weylus/weylus" ] && alias weylus="$HOME/.local/bin/weylus/weylus"
command -v adb >/dev/null 2>&1 && alias tablet='adb reverse tcp:1701 tcp:1701 && adb reverse tcp:9001 tcp:9001'

# Notify when a long-running command finishes:  sleep 10; alert
command -v notify-send >/dev/null 2>&1 && \
  alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
