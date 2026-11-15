#!/bin/zsh

set -e

REPO_SLUG="mp-lb/macsetup"
RAW_BASE="https://raw.githubusercontent.com/$REPO_SLUG/main"

source <(curl -fsSL "$RAW_BASE/lib/output.sh")
source <(curl -fsSL "$RAW_BASE/lib/paths.sh")

log "Starting macsetup."
mkdir -p "$MACSETUP_WORKSPACE"

command -v brew >/dev/null 2>&1 || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
export PATH="/opt/homebrew/bin:$PATH"

if ! command -v gh >/dev/null 2>&1; then
  brew install gh
fi

log "Configuring GitHub authentication and Git credentials."
gh auth status --hostname github.com >/dev/null 2>&1 || gh auth login --hostname github.com
gh auth setup-git --hostname github.com

if [ -d "$MACSETUP_REPO_PATH/.git" ]; then
  note "Using existing repository at $MACSETUP_REPO_PATH."
else
  gh repo clone "$REPO_SLUG" "$MACSETUP_REPO_PATH"
fi

log "Installing Homebrew bundle."
brew bundle --file "$MACSETUP_REPO_PATH/Brewfile"

[ -d "$HOME/.oh-my-zsh" ] || KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

if ! git config --global user.name >/dev/null || ! git config --global user.email >/dev/null; then
  log "Configuring git."
  read "git_name?Enter your full name for git commits: "
  read "git_email?Enter your email for git commits: "
  git config --global user.name "$git_name"
  git config --global user.email "$git_email"
else
  note "Git user is already configured."
fi

log "Installing shell bridge."
{
  printf 'export MACSETUP_WORKSPACE=%q\n' "$MACSETUP_WORKSPACE"
  printf 'export MACSETUP_REPO_PATH=%q\n' "$MACSETUP_REPO_PATH"
  cat "$MACSETUP_REPO_PATH/env/home-zshrc"
} > "$HOME/.zshrc"

log "Installing AWS config."
mkdir -p "$HOME/.aws"
install -m 600 "$MACSETUP_REPO_PATH/env/aws-config" "$HOME/.aws/config"

log "Installing default mise tools."
export PATH="$HOME/.local/bin:$PATH"
eval "$(mise activate zsh)"
mise use --global node@lts pnpm@latest
mise install

log "Installing global Node CLIs."
mise exec -- npm install -g @mp-lb/forum-cli @mp-lb/berth @mp-lb/zapper pm2 clerk

log "Trusting the workspace in Claude Code."
mise exec -- node "$MACSETUP_REPO_PATH/lib/claude-trust.mjs" "$MACSETUP_WORKSPACE"

log "Installing global agent skills."
"$MACSETUP_REPO_PATH/bin/install-skills"

success "Macsetup finished."
note "Run: $MACSETUP_REPO_PATH/doctor.sh"
