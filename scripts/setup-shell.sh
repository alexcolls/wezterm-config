#!/usr/bin/env bash
# Hook this repo's shell config into ~/.bashrc, without clobbering it.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

step "Shell (bash)"

RC="${BASHRC:-$HOME/.bashrc}"
BEGIN='# >>> wezterm-config >>>'
END='# <<< wezterm-config <<<'

[ -f "$RC" ] || run touch "$RC"

# Back up, then drop any previous block so re-running stays idempotent
# (and picks the repo up from its new location if it moved).
if [ "$DRY_RUN" != "1" ]; then
  cp "$RC" "$RC.bak.$(date +%Y%m%d-%H%M%S)"
  if grep -qF "$BEGIN" "$RC"; then
    info "refreshing the existing block in $RC"
    awk -v b="$BEGIN" -v e="$END" '
      index($0, b) { inblock = 1 }
      !inblock     { print }
      index($0, e) { inblock = 0 }
    ' "$RC" > "$RC.new" && mv "$RC.new" "$RC"
  fi
fi

if [ "$DRY_RUN" = "1" ]; then
  skip "would append the sourcing block to $RC"
else
  cat >> "$RC" <<BLOCK

$BEGIN
# Managed by $REPO_DIR — see its README.
# Machine-specific settings belong in config/shell/local.sh, not here.
if [ -r "$REPO_DIR/config/shell/bashrc.sh" ]; then
    . "$REPO_DIR/config/shell/bashrc.sh"
fi
$END
BLOCK
fi

ok "$RC sources config/shell/bashrc.sh"
skip "existing lines in $RC are untouched; a timestamped .bak sits next to it"
