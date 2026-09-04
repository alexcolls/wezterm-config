#!/usr/bin/env bash
# Environment & PATH — sourced by config/shell/bashrc.sh
# Every entry is guarded, so this file is safe on a machine that has none of it.
# shellcheck shell=bash

# --- editor / pager ---------------------------------------------------------
if command -v nvim >/dev/null 2>&1; then export EDITOR=nvim
elif command -v vim >/dev/null 2>&1; then export EDITOR=vim
else export EDITOR=nano
fi
export VISUAL="$EDITOR"
export PAGER=less
export LESS='-R -F -X'

# --- locale & colors --------------------------------------------------------
export LANG="${LANG:-en_US.UTF-8}"
export CLICOLOR=1
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# --- history ----------------------------------------------------------------
export HISTCONTROL=ignoreboth:erasedups
export HISTSIZE=50000
export HISTFILESIZE=100000
export HISTTIMEFORMAT='%F %T  '
export HISTIGNORE='ls:ll:la:cd:pwd:exit:x:cl:clear:history'

# --- PATH -------------------------------------------------------------------
# path_prepend <dir> — add to PATH only if it exists and isn't already there.
path_prepend() {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) [ -d "$1" ] && PATH="$1:$PATH" ;;
  esac
}

path_prepend "$HOME/bin"
path_prepend "$HOME/.local/bin"
path_prepend "$HOME/.cargo/bin"
path_prepend "$HOME/go/bin"
path_prepend "$HOME/.bun/bin"
path_prepend "$HOME/.deno/bin"
path_prepend "$HOME/.fly/bin"
path_prepend "$HOME/.modular/bin"
path_prepend "$HOME/.supabase/bin"
path_prepend "$HOME/development/flutter/bin"
export PATH

# pnpm
if [ -d "$HOME/.local/share/pnpm" ]; then
  export PNPM_HOME="$HOME/.local/share/pnpm"
  path_prepend "$PNPM_HOME"
  export PATH
fi

# rust
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# --- misc -------------------------------------------------------------------
# Let WezTerm's shell integration and image protocols work over ssh, too.
export TERM="${TERM:-xterm-256color}"
