#!/usr/bin/env bash
# Install Starship — the prompt this config draws.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

step "Starship prompt"

if have starship && [ "${FORCE:-0}" != "1" ]; then
  ok "already installed ($(starship --version | head -1))"
  return 0 2>/dev/null || exit 0
fi

if [ "$(pkg_manager)" = "brew" ]; then
  run brew install starship
elif have cargo && [ "${PREFER_CARGO:-0}" = "1" ]; then
  run cargo install starship --locked
else
  have curl || die "curl is required to install starship"
  info "installing via the official script (starship.rs) into /usr/local/bin"
  if [ "$DRY_RUN" = "1" ]; then
    skip "would run: curl -sS https://starship.rs/install.sh | sh -s -- --yes"
  else
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
  fi
fi

have starship && ok "installed $(starship --version | head -1)"
