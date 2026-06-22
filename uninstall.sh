#!/bin/zsh

set -e

SCRIPT_DIR="${0:A:h}"
source "$SCRIPT_DIR/lib/output.sh"
source "$SCRIPT_DIR/lib/paths.sh"

log "Removing legacy macsetup-managed runtimes."

if [ -f "$HOME/.nvm/nvm.sh" ]; then
  source "$HOME/.nvm/nvm.sh"
  npm uninstall -g pnpm pm2 zapper-cli @mp-lb/zapper clerk 2>/dev/null || true
fi

rm -rf "$HOME/.nvm"
rm -rf "$HOME/.pyenv"
rm -rf "$HOME/.rbenv"
rm -rf "$HOME/google-cloud-sdk"
rm -rf "$HOME/Library/pnpm"
rm -rf "$HOME/.config/pypoetry"

if [ "${1:-}" = "--all" ]; then
  log "Removing current mise-managed runtime state."
  rm -rf "$HOME/.local/share/mise"
  rm -rf "$HOME/.config/mise"
fi

if [ -f "$HOME/.zshrc" ] && grep -q 'MACSETUP_REPO_PATH/env/zshrc' "$HOME/.zshrc"; then
  rm -f "$HOME/.zshrc"
fi

success "Legacy macsetup-managed runtime cleanup complete."
note "Homebrew, gh auth, git config, $MACSETUP_WORKSPACE, and project files were intentionally left in place."
