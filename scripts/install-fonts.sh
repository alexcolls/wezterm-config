#!/usr/bin/env bash
# Install FiraCode Nerd Font — the font wezterm.lua asks for.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

FONT_NAME="${FONT_NAME:-FiraCode}"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${FONT_NAME}.zip"

step "Fonts — ${FONT_NAME} Nerd Font"

if [ "$(os_name)" = "macos" ]; then
  FONT_DIR="$HOME/Library/Fonts/$FONT_NAME"
else
  FONT_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fonts/$FONT_NAME"
fi

# grep -c (not -q) so grep drains the pipe: with `set -o pipefail`, an early
# -q exit kills the upstream command with SIGPIPE and fails the whole test.
if have fc-list && fc-list | grep -ci "${FONT_NAME} Nerd Font" >/dev/null && [ "${FORCE:-0}" != "1" ]; then
  ok "already installed ($(fc-list | grep -ci "${FONT_NAME} Nerd Font") faces)"
  return 0 2>/dev/null || exit 0
fi

if [ "$(os_name)" = "macos" ] && have brew && [ "${PREFER_BREW:-1}" = "1" ]; then
  run brew install --cask font-fira-code-nerd-font && { ok "installed via Homebrew"; exit 0; }
fi

have curl || die "curl is required to download fonts"
have unzip || die "unzip is required to unpack fonts"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

info "downloading $FONT_URL"
if [ "$DRY_RUN" = "1" ]; then
  skip "would download and unpack into $FONT_DIR"
else
  curl -fL --progress-bar -o "$tmp/font.zip" "$FONT_URL" \
    || die "download failed — check the font name or your connection"
  mkdir -p "$FONT_DIR"
  unzip -q -o "$tmp/font.zip" -d "$FONT_DIR" -x 'LICENSE*' 'README*' '*.md'
  have fc-cache && fc-cache -f "$FONT_DIR" >/dev/null 2>&1
fi

ok "installed into $FONT_DIR"
