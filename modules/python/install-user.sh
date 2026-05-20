#!/bin/zsh

set -e

source <(curl -fsSL https://raw.githubusercontent.com/felixsebastian/macsetup/main/lib/output.sh)

log "Installing Python (user)."
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init - zsh)"

command -v uv >/dev/null 2>&1 || (curl -LsSf https://astral.sh/uv/install.sh | sh)

poetry --version >/dev/null 2>&1 || uv tool install --force --managed-python poetry
poetry config virtualenvs.in-project true

pyenv install 3:latest || true
pyenv global $(pyenv versions --bare | tail -1)
success "Python (user) installation complete."
