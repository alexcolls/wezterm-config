#!/usr/bin/env bash
# Put the config files where the tools look for them.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

step "Config files (${LINK_MODE})"

install_file "$CONFIG_DIR/wezterm/wezterm.lua"    "${XDG_CONFIG_HOME:-$HOME/.config}/wezterm/wezterm.lua"
install_file "$CONFIG_DIR/starship/starship.toml" "${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"
install_file "$CONFIG_DIR/git/gitignore_global"   "$HOME/.gitignore_global"

if [ ! -e "$CONFIG_DIR/shell/local.sh" ] && [ "$DRY_RUN" != "1" ]; then
  cp "$CONFIG_DIR/shell/local.sh.example" "$CONFIG_DIR/shell/local.sh"
  ok "created config/shell/local.sh for machine-specific settings (gitignored)"
fi
