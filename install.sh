#!/usr/bin/env bash
#
#  wezterm-config — one script to reproduce this terminal setup on a new box.
#
#    ./install.sh                 everything, asking before anything invasive
#    ./install.sh --dry-run       show what it would do, touch nothing
#    ./install.sh -y              no questions
#    ./install.sh --skip-wezterm  configs only, leave the terminal alone
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SKIP_WEZTERM=0 SKIP_FONTS=0 SKIP_STARSHIP=0
SKIP_SHELL=0 SKIP_GIT=0 SKIP_DESKTOP=0
export DRY_RUN=0 ASSUME_YES=0 LINK_MODE=symlink FORCE=0

usage() {
  cat <<'USAGE'
Usage: ./install.sh [options]

What it does
  1. installs WezTerm            (apt / dnf / pacman / brew / flatpak)
  2. installs FiraCode Nerd Font (the font wezterm.lua asks for)
  3. installs Starship           (the prompt)
  4. links the configs           wezterm.lua, starship.toml, gitignore_global
  5. hooks bash up               a single sourcing block appended to ~/.bashrc
  6. wires git up                shared aliases/settings included from ~/.gitconfig
  7. desktop integration         optional: Ctrl+Alt+T opens WezTerm

Options
  -y, --yes           don't ask, assume yes
  -n, --dry-run       print the steps without changing anything
      --copy          copy the config files instead of symlinking them
      --force         reinstall packages even when they're already present
      --skip-wezterm  --skip-fonts  --skip-starship
      --skip-shell    --skip-git    --skip-desktop
  -h, --help          this text

Anything it replaces is backed up under ~/.dotfiles-backup/<timestamp>/,
and ~/.bashrc gets a timestamped .bak before it's touched.
USAGE
}

while [ $# -gt 0 ]; do
  case "$1" in
    -y|--yes)        ASSUME_YES=1 ;;
    -n|--dry-run)    DRY_RUN=1 ;;
    --copy)          LINK_MODE=copy ;;
    --force)         FORCE=1 ;;
    --skip-wezterm)  SKIP_WEZTERM=1 ;;
    --skip-fonts)    SKIP_FONTS=1 ;;
    --skip-starship) SKIP_STARSHIP=1 ;;
    --skip-shell)    SKIP_SHELL=1 ;;
    --skip-git)      SKIP_GIT=1 ;;
    --skip-desktop)  SKIP_DESKTOP=1 ;;
    -h|--help)       usage; exit 0 ;;
    *)               echo "unknown option: $1" >&2; usage; exit 1 ;;
  esac
  shift
done

export BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
. "$REPO_DIR/scripts/lib.sh"

cat <<BANNER
${C_PINK}${C_BOLD}
   ┌────────────────────────────────────────────┐
   │  wezterm-config · terminal setup installer │
   └────────────────────────────────────────────┘${C_RESET}
   ${C_DIM}repo   ${C_RESET}$REPO_DIR
   ${C_DIM}system ${C_RESET}$(os_name) · $(pkg_manager) · bash ${BASH_VERSION%%(*}
   ${C_DIM}mode   ${C_RESET}$LINK_MODE$([ "$DRY_RUN" = 1 ] && echo " · DRY RUN" || true)
BANNER

[ "$DRY_RUN" = "1" ] && warn "dry run — nothing will be written"

if [ "$ASSUME_YES" != "1" ] && [ "$DRY_RUN" != "1" ]; then
  confirm "
Proceed?" y || { echo "aborted."; exit 0; }
fi

run_step() {  # run_step <skip-flag> <script>
  [ "$1" = "1" ] && { skip "skipped: $(basename "$2" .sh)"; return 0; }
  bash "$REPO_DIR/scripts/$2"
}

run_step "$SKIP_WEZTERM"  install-wezterm.sh
run_step "$SKIP_FONTS"    install-fonts.sh
run_step "$SKIP_STARSHIP" install-starship.sh
run_step 0                link-configs.sh
run_step "$SKIP_SHELL"    setup-shell.sh
run_step "$SKIP_GIT"      setup-git.sh
run_step "$SKIP_DESKTOP"  setup-desktop.sh

step "Done"
[ -d "$BACKUP_DIR" ] && info "replaced files are in $BACKUP_DIR"
cat <<NEXT

   ${C_GREEN}Terminal is set up.${C_RESET}

   ${C_CYAN}next${C_RESET}  open a new WezTerm window, or: ${C_BOLD}source ~/.bashrc${C_RESET}
   ${C_CYAN}keys${C_RESET}  Alt+1..0 switch theme · Alt+Enter fullscreen · Alt+R rename tab
         Shift+Alt+Arrow split · Alt+Arrow move between panes · Ctrl+Tab next tab
   ${C_CYAN}edit${C_RESET}  configs live in $REPO_DIR/config — they're symlinked, so
         changes apply on the next reload. Machine-specific bits go in
         config/shell/local.sh (gitignored).
NEXT
