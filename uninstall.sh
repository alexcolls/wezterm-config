#!/usr/bin/env bash
# Undo what install.sh linked and hooked up. Packages (WezTerm, Starship, the
# font) are left alone — remove those with your package manager if you want to.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DRY_RUN="${DRY_RUN:-0}" ASSUME_YES="${ASSUME_YES:-0}"
[ "${1:-}" = "-n" ] || [ "${1:-}" = "--dry-run" ] && export DRY_RUN=1
[ "${1:-}" = "-y" ] || [ "${1:-}" = "--yes" ] && export ASSUME_YES=1
. "$REPO_DIR/scripts/lib.sh"

step "Removing the config links"
for f in "${XDG_CONFIG_HOME:-$HOME/.config}/wezterm/wezterm.lua" \
         "${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml" \
         "$HOME/.gitignore_global"; do
  if [ -L "$f" ] && [[ "$(readlink -f "$f")" == "$REPO_DIR"/* ]]; then
    run rm "$f"; ok "removed $f"
  elif [ -e "$f" ]; then
    skip "left $f alone (not a link into this repo)"
  fi
done

step "Unhooking ~/.bashrc"
RC="$HOME/.bashrc"
BEGIN='# >>> wezterm-config >>>'
END='# <<< wezterm-config <<<'
if grep -qF "$BEGIN" "$RC" 2>/dev/null; then
  if [ "$DRY_RUN" != "1" ]; then
    cp "$RC" "$RC.bak.$(date +%Y%m%d-%H%M%S)"
    awk -v b="$BEGIN" -v e="$END" '
      index($0, b) { inblock = 1 }
      !inblock     { print }
      index($0, e) { inblock = 0 }
    ' "$RC" > "$RC.new" && mv "$RC.new" "$RC"
  fi
  ok "block removed from $RC"
else
  skip "no block in $RC"
fi

step "Unhooking git"
if git config --global --get-all include.path 2>/dev/null | grep -cxF "$REPO_DIR/config/git/gitconfig" >/dev/null; then
  run git config --global --unset-all include.path "$(printf '%s' "$REPO_DIR/config/git/gitconfig" | sed 's/[].[^$*\/]/\\&/g')"
  ok "include removed from ~/.gitconfig"
else
  skip "~/.gitconfig doesn't include this repo"
fi

step "Done"
info "backups of anything install.sh replaced are under ~/.dotfiles-backup/"
