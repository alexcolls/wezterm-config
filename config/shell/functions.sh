#!/usr/bin/env bash
# Small shell functions — sourced by config/shell/bashrc.sh
# shellcheck shell=bash

# mkcd <dir> — create a directory and step into it.
mkcd() { mkdir -p -- "$1" && cd -- "$1" || return; }

# up [n] — climb n directories (default 1).
up() {
  local n="${1:-1}" p=""
  while [ "$n" -gt 0 ]; do p="../$p"; n=$((n - 1)); done
  cd "${p:-.}" || return
}

# extract <archive> — unpack whatever it is.
extract() {
  [ -f "$1" ] || { echo "extract: '$1' is not a file" >&2; return 1; }
  case "$1" in
    *.tar.bz2|*.tbz2) tar xjf "$1" ;;
    *.tar.gz|*.tgz)   tar xzf "$1" ;;
    *.tar.xz)         tar xJf "$1" ;;
    *.tar)            tar xf  "$1" ;;
    *.bz2)            bunzip2 "$1" ;;
    *.gz)             gunzip  "$1" ;;
    *.zip)            unzip   "$1" ;;
    *.7z)             7z x    "$1" ;;
    *.rar)            unrar x "$1" ;;
    *)                echo "extract: don't know how to open '$1'" >&2; return 1 ;;
  esac
}

# ff <pattern> — find files by name below the current directory.
ff() { find . -iname "*$1*" -not -path '*/.git/*' 2>/dev/null; }

# gcl <repo> — clone and cd into it.
gcl() { git clone "$1" && cd "$(basename "$1" .git)" || return; }

# --- WezTerm: open new terminals from the shell -----------------------------
if command -v wezterm >/dev/null 2>&1; then
  # nt [dir] — new tab in the current WezTerm window, same directory.
  nt() { wezterm cli spawn --cwd "${1:-$PWD}" >/dev/null; }

  # nw [dir] — brand new WezTerm window.
  nw() { wezterm cli spawn --new-window --cwd "${1:-$PWD}" >/dev/null 2>&1 \
         || (wezterm start --cwd "${1:-$PWD}" >/dev/null 2>&1 &); }

  # vs / hs [dir] — split the current pane vertically / horizontally.
  vs() { wezterm cli split-pane --bottom --cwd "${1:-$PWD}" >/dev/null; }
  hs() { wezterm cli split-pane --right  --cwd "${1:-$PWD}" >/dev/null; }
fi
