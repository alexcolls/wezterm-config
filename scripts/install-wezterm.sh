#!/usr/bin/env bash
# Install the WezTerm terminal emulator.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

step "WezTerm"

if have wezterm && [ "${FORCE:-0}" != "1" ]; then
  ok "already installed ($(wezterm --version 2>/dev/null || echo present))"
  return 0 2>/dev/null || exit 0
fi

case "$(pkg_manager)" in
  apt)
    info "adding the official WezTerm apt repository (apt.fury.io/wez)"
    have curl || sudo_cmd apt-get install -y curl
    if [ ! -f /usr/share/keyrings/wezterm-fury.gpg ]; then
      if [ "$DRY_RUN" = "1" ]; then
        skip "would fetch and dearmor the WezTerm signing key"
      else
        curl -fsSL https://apt.fury.io/wez/gpg.key \
          | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
        sudo chmod 644 /usr/share/keyrings/wezterm-fury.gpg
      fi
    fi
    if [ "$DRY_RUN" = "1" ]; then
      skip "would write /etc/apt/sources.list.d/wezterm.list"
    else
      echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' \
        | sudo tee /etc/apt/sources.list.d/wezterm.list >/dev/null
    fi
    sudo_cmd apt-get update
    sudo_cmd apt-get install -y wezterm
    ;;
  dnf)
    sudo_cmd dnf copr enable -y wezfurlong/wezterm-nightly
    sudo_cmd dnf install -y wezterm
    ;;
  pacman)
    sudo_cmd pacman -S --needed --noconfirm wezterm ttf-nerd-fonts-symbols-mono
    ;;
  zypper)
    sudo_cmd zypper --non-interactive install wezterm || {
      warn "no wezterm package for zypper — see https://wezterm.org/install/linux.html"
    }
    ;;
  brew)
    run brew install --cask wezterm
    ;;
  *)
    if have flatpak; then
      info "no supported package manager — falling back to Flatpak"
      run flatpak install -y flathub org.wezfurlong.wezterm
    else
      err "couldn't work out how to install WezTerm on this system."
      err "Grab it from https://wezterm.org/installation.html and re-run with --skip-wezterm."
      exit 1
    fi
    ;;
esac

have wezterm && ok "installed $(wezterm --version)"
