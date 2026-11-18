#!/usr/bin/env bash
# Entry point for this repo's shell configuration.
#
# ~/.bashrc sources THIS file (see scripts/setup-shell.sh); everything else
# hangs off it. Order matters: exports -> options -> aliases -> functions ->
# prompt -> local overrides.
# shellcheck shell=bash

# Interactive shells only.
case $- in *i*) ;; *) return ;; esac

DOTFILES_SHELL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR="$(cd "$DOTFILES_SHELL_DIR/../.." && pwd)"

# --- shell options ----------------------------------------------------------
shopt -s histappend      # append to history, don't clobber it
shopt -s checkwinsize    # keep $LINES/$COLUMNS right after each command
shopt -s globstar        # ** matches across directories
shopt -s cdspell         # fix small typos in cd targets
shopt -s dirspell        # ...and in directory completion
shopt -s autocd 2>/dev/null   # `..` alone works as `cd ..`
shopt -s no_empty_cmd_completion

# Share history across panes/tabs as soon as a command finishes.
PROMPT_COMMAND="history -a; history -c; history -r${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

# --- pieces -----------------------------------------------------------------
for _f in exports.sh aliases.sh functions.sh; do
  [ -r "$DOTFILES_SHELL_DIR/$_f" ] && . "$DOTFILES_SHELL_DIR/$_f"
done
unset _f

# --- completion -------------------------------------------------------------
if ! shopt -oq posix; then
  if [ -r /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -r /etc/bash_completion ]; then
    . /etc/bash_completion
  elif [ -r /opt/homebrew/etc/profile.d/bash_completion.sh ]; then
    . /opt/homebrew/etc/profile.d/bash_completion.sh
  fi
fi

# make less friendlier for non-text input
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# WezTerm shell integration: reports the cwd (OSC 7) so new tabs, windows and
# splits open where you already are. /etc/profile.d is not read by the
# non-login shell WezTerm spawns, so source it here.
[ -r /etc/profile.d/wezterm.sh ] && . /etc/profile.d/wezterm.sh
# The Flatpak build ships no wezterm.sh, so also emit OSC 7 ourselves.
__wezterm_osc7() { printf '\033]7;file://%s%s\033\\' "${HOSTNAME}" "${PWD// /%20}"; }
case ";${PROMPT_COMMAND};" in *";__wezterm_osc7;"*) ;; *) PROMPT_COMMAND="__wezterm_osc7${PROMPT_COMMAND:+;$PROMPT_COMMAND}";; esac

# --- prompt -----------------------------------------------------------------
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
else
  # Fallback that mimics the starship prompt in config/starship/starship.toml:
  #   directory (mint) + git branch (cyan) + ❯ (hot pink)
  __dot_git_branch() {
    local b
    b="$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)" || return
    printf ' \001\033[1;36m\002 %s\001\033[0m\002' "$b"
  }
  PS1='\[\033[1;38;5;48m\]\w\[\033[0m\]$(__dot_git_branch) \[\033[1;38;5;198m\]❯\[\033[0m\] '
fi

# --- machine-specific overrides (never committed) ---------------------------
[ -r "$DOTFILES_SHELL_DIR/local.sh" ] && . "$DOTFILES_SHELL_DIR/local.sh"
[ -r "$HOME/.bashrc.local" ] && . "$HOME/.bashrc.local"
