#!/usr/bin/env bash
# Shared helpers for the installer scripts.

# --- paths ------------------------------------------------------------------
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$REPO_DIR/config"
BACKUP_DIR="${BACKUP_DIR:-$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)}"

# --- flags (exported by install.sh) -----------------------------------------
DRY_RUN="${DRY_RUN:-0}"
ASSUME_YES="${ASSUME_YES:-0}"
LINK_MODE="${LINK_MODE:-symlink}"   # symlink | copy

# --- output -----------------------------------------------------------------
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  C_RESET=$'\033[0m'; C_DIM=$'\033[2m'; C_BOLD=$'\033[1m'
  C_PINK=$'\033[38;5;198m'; C_CYAN=$'\033[38;5;51m'
  C_GREEN=$'\033[38;5;48m'; C_YELLOW=$'\033[38;5;227m'; C_RED=$'\033[38;5;203m'
else
  C_RESET=; C_DIM=; C_BOLD=; C_PINK=; C_CYAN=; C_GREEN=; C_YELLOW=; C_RED=
fi

info()  { printf '%s\n' "${C_CYAN}::${C_RESET} $*"; }
ok()    { printf '%s\n' "${C_GREEN} ✔${C_RESET} $*"; }
warn()  { printf '%s\n' "${C_YELLOW} !${C_RESET} $*" >&2; }
err()   { printf '%s\n' "${C_RED} ✘${C_RESET} $*" >&2; }
step()  { printf '\n%s\n' "${C_PINK}${C_BOLD}▸ $*${C_RESET}"; }
skip()  { printf '%s\n' "${C_DIM} - $*${C_RESET}"; }
die()   { err "$*"; exit 1; }

run() {
  if [ "$DRY_RUN" = "1" ]; then
    printf '%s\n' "${C_DIM}   would run: $*${C_RESET}"
  else
    "$@"
  fi
}

confirm() {
  # confirm "question" [default:y|n]
  local prompt="$1" default="${2:-y}" reply
  [ "$ASSUME_YES" = "1" ] && return 0
  if [ ! -t 0 ]; then return 0; fi   # non-interactive: take the default path
  if [ "$default" = "y" ]; then prompt="$prompt [Y/n] "; else prompt="$prompt [y/N] "; fi
  read -r -p "$prompt" reply
  reply="${reply:-$default}"
  [[ "$reply" =~ ^[Yy]$ ]]
}

have() { command -v "$1" >/dev/null 2>&1; }

# --- platform ---------------------------------------------------------------
os_name() {
  case "$(uname -s)" in
    Linux)  echo linux ;;
    Darwin) echo macos ;;
    *)      echo unknown ;;
  esac
}

# Prints: apt | dnf | pacman | zypper | brew | none
pkg_manager() {
  if have apt-get; then echo apt
  elif have dnf;    then echo dnf
  elif have pacman; then echo pacman
  elif have zypper; then echo zypper
  elif have brew;   then echo brew
  else echo none
  fi
}

sudo_cmd() {
  if [ "$(id -u)" -eq 0 ]; then run "$@"; else run sudo "$@"; fi
}

# --- filesystem -------------------------------------------------------------
backup_path() {
  # Move an existing file/dir/symlink out of the way, into $BACKUP_DIR.
  local target="$1"
  [ -e "$target" ] || [ -L "$target" ] || return 0
  run mkdir -p "$BACKUP_DIR"
  run mv "$target" "$BACKUP_DIR/$(basename "$target")"
  skip "backed up $target -> $BACKUP_DIR/$(basename "$target")"
}

install_file() {
  # install_file <source-in-repo> <destination>
  # Symlinks (default) or copies, backing up whatever was there before.
  local src="$1" dst="$2"
  [ -e "$src" ] || die "missing source file: $src"

  if [ "$LINK_MODE" = "symlink" ] && [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$(readlink -f "$src")" ]; then
    skip "already linked: $dst"
    return 0
  fi

  run mkdir -p "$(dirname "$dst")"
  backup_path "$dst"
  if [ "$LINK_MODE" = "copy" ]; then
    run cp "$src" "$dst"
    ok "copied  $dst"
  else
    run ln -s "$src" "$dst"
    ok "linked  $dst -> ${src#"$REPO_DIR"/}"
  fi
}
