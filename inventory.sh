#!/bin/zsh

set -e

export PATH="/opt/homebrew/bin:$HOME/.local/bin:$PATH"

if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

print_version() {
  local label="$1"
  local command_name="$2"
  shift 2

  if command -v "$command_name" >/dev/null 2>&1; then
    printf "%-18s %s\n" "$label" "$("$command_name" "$@" 2>&1 | awk 'NF { print; exit }')"
  else
    printf "%-18s missing\n" "$label"
  fi
}

echo "macsetup inventory"
echo
print_version "brew" brew --version
print_version "gh" gh --version
print_version "mise" mise --version
print_version "node" node --version
print_version "npm" npm --version
print_version "pnpm" pnpm --version
print_version "zap" zap --version
print_version "aws" aws --version
print_version "gcloud" gcloud --version
print_version "docker" docker --version

echo
echo "mise tools"
if command -v mise >/dev/null 2>&1; then
  mise list || true
else
  echo "mise missing"
fi

echo
echo "homebrew bundle"
if command -v brew >/dev/null 2>&1; then
  brew bundle check --file "$HOME/Code/macsetup/Brewfile" || true
else
  echo "brew missing"
fi
