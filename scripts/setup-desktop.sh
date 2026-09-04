#!/usr/bin/env bash
# Optional: make WezTerm the system terminal (Ctrl+Alt+T and "Open in terminal").
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

step "Desktop integration (optional)"

if [ "$(os_name)" != "linux" ]; then
  skip "not Linux — nothing to do"
  return 0 2>/dev/null || exit 0
fi

have wezterm || { warn "wezterm not on PATH — skipping"; return 0 2>/dev/null || exit 0; }

if ! confirm "   make WezTerm the default terminal (Ctrl+Alt+T)?" y; then
  skip "left the default terminal alone"
  return 0 2>/dev/null || exit 0
fi

WEZTERM_BIN="$(command -v wezterm)"

# GNOME: Ctrl+Alt+T launches whatever this points at.
if have gsettings && gsettings list-schemas 2>/dev/null | grep -c '^org.gnome.desktop.default-applications.terminal$' >/dev/null; then
  run gsettings set org.gnome.desktop.default-applications.terminal exec "$WEZTERM_BIN"
  run gsettings set org.gnome.desktop.default-applications.terminal exec-arg "start --"
  ok "GNOME: Ctrl+Alt+T opens WezTerm"
fi

# XFCE
if have xfconf-query; then
  run xfconf-query -c xfce4-session -p /sessions/Failsafe/Client0_Command -n -t string -s "$WEZTERM_BIN" 2>/dev/null || true
fi

# Debian/Ubuntu alternatives system ("Open in terminal", x-terminal-emulator).
if have update-alternatives && [ -e /usr/bin/wezterm ]; then
  sudo_cmd update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/wezterm 60 || true
  sudo_cmd update-alternatives --set x-terminal-emulator /usr/bin/wezterm || true
  ok "x-terminal-emulator points at WezTerm"
fi

# XDG default for terminal-emulator (only some desktops know this property).
if have xdg-settings && xdg-settings --list 2>/dev/null | grep -c default-terminal-emulator >/dev/null; then
  run xdg-settings set default-terminal-emulator org.wezfurlong.wezterm.desktop >/dev/null 2>&1 \
    && ok "xdg default terminal set" || true
fi
