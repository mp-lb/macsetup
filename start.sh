#!/bin/zsh

set -e

source <(curl -fsSL https://raw.githubusercontent.com/felixsebastian/macsetup/main/lib/output.sh)

log "Starting complete macsetup installation."
mkdir -p "$HOME/Code"

command -v brew >/dev/null 2>&1 || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
BREW=/opt/homebrew/bin
export PATH="$BREW:$PATH"
brew install gh go-task/tap/go-task awscli tmux overmind

gh auth status >/dev/null 2>&1 || gh auth login

if [ -d "$HOME/Code/macsetup/.git" ]; then
  note "Using existing repository at $HOME/Code/macsetup."
else
  gh repo clone felixsebastian/macsetup "$HOME/Code/macsetup"
fi

[ -d "$HOME/.oh-my-zsh" ] || KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

log "Configuring git..."
read "git_name?Enter your full name for git commits: "
read "git_email?Enter your email for git commits: "
git config --global user.name "$git_name"
git config --global user.email "$git_email"

cp "$HOME/Code/macsetup/payloads/zshrc" "$HOME/.zshrc"
cp "$HOME/Code/macsetup/payloads/sandbox.sh" "$HOME/sandbox.sh"

/bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/felixsebastian/macsetup/main/modules/node/install.sh)"
/bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/felixsebastian/macsetup/main/modules/python/install.sh)"
/bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/felixsebastian/macsetup/main/modules/ruby/install.sh)"
/bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/felixsebastian/macsetup/main/modules/gcloud/install.sh)"

success "Complete macsetup installation finished."
