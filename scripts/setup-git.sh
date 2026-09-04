#!/usr/bin/env bash
# Wire the shared git config into ~/.gitconfig and make sure identity is set.
set -euo pipefail
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

step "Git"

have git || die "git is not installed"

SHARED="$CONFIG_DIR/git/gitconfig"

if git config --global --get-all include.path 2>/dev/null | grep -cxF "$SHARED" >/dev/null; then
  skip "~/.gitconfig already includes the shared config"
else
  run git config --global --add include.path "$SHARED"
  ok "~/.gitconfig now includes ${SHARED#"$REPO_DIR"/}"
fi

run git config --global core.excludesfile "$HOME/.gitignore_global"

# Identity lives in ~/.gitconfig, never in the repo.
name="$(git config --global --get user.name  || true)"
email="$(git config --global --get user.email || true)"

if [ -z "$name" ] || [ -z "$email" ]; then
  if [ -t 0 ] && [ "$ASSUME_YES" != "1" ]; then
    [ -z "$name" ]  && { read -r -p "   git user.name:  " name;  [ -n "$name" ]  && run git config --global user.name  "$name"; }
    [ -z "$email" ] && { read -r -p "   git user.email: " email; [ -n "$email" ] && run git config --global user.email "$email"; }
  else
    warn "git user.name / user.email are unset — set them with:"
    warn "   git config --global user.name  \"Your Name\""
    warn "   git config --global user.email \"you@example.com\""
  fi
fi
[ -n "$name" ] && ok "identity: $name <$email>"

# GitHub CLI as the credential helper, when it's around.
if have gh && ! git config --global --get-regexp 'credential.*helper' 2>/dev/null | grep -c 'gh auth' >/dev/null; then
  if confirm "   use the GitHub CLI (gh) as the credential helper?" y; then
    for host in https://github.com https://gist.github.com; do
      run git config --global --unset-all "credential.$host.helper" 2>/dev/null || true
      run git config --global --add "credential.$host.helper" ""
      run git config --global --add "credential.$host.helper" "!$(command -v gh) auth git-credential"
    done
    ok "gh is handling GitHub credentials"
  fi
fi
