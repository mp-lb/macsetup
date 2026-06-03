#!/bin/zsh

set -e

SCRIPT_DIR="${0:A:h}"
source "$SCRIPT_DIR/lib/output.sh"

failures=0

check_command() {
  local name="$1"
  local command_name="$2"
  shift 2

  if command -v "$command_name" >/dev/null 2>&1; then
    if [ "$#" -gt 0 ] && ! "$command_name" "$@" >/dev/null 2>&1; then
      error "$name: command exists but health check failed"
      failures=$((failures + 1))
      return
    fi

    success "$name: $(command -v "$command_name")"
  else
    error "$name: missing command '$command_name'"
    failures=$((failures + 1))
  fi
}

check_absent_dir() {
  local label="$1"
  local dir="$2"

  if [ -d "$dir" ]; then
    error "$label: legacy directory still exists at $dir"
    failures=$((failures + 1))
  else
    success "$label: absent"
  fi
}

check_recommended_command() {
  local name="$1"
  local command_name="$2"
  shift 2

  if command -v "$command_name" >/dev/null 2>&1; then
    if [ "$#" -gt 0 ] && ! "$command_name" "$@" >/dev/null 2>&1; then
      note "$name: optional command '$command_name' is installed but unhealthy"
      return
    fi

    success "$name: $(command -v "$command_name")"
  else
    note "$name: optional command '$command_name' is not installed"
  fi
}

export PATH="/opt/homebrew/bin:$HOME/.local/bin:$PATH"

if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

log "Checking host tools."
check_command "Homebrew" brew
check_command "GitHub CLI" gh
check_command "mise" mise
check_command "Node" node --version
check_command "pnpm" pnpm --version
check_command "Zapper" zap --version
check_recommended_command "AWS CLI" aws --version
check_recommended_command "Google Cloud CLI" gcloud
check_recommended_command "OrbStack/Docker" docker --version

log "Checking legacy runtime cleanup."
check_absent_dir "nvm" "$HOME/.nvm"
check_absent_dir "pyenv" "$HOME/.pyenv"
check_absent_dir "rbenv" "$HOME/.rbenv"
check_absent_dir "old gcloud installer" "$HOME/google-cloud-sdk"

if [ -f "$HOME/.zshrc" ] && grep -q "Code/macsetup/env/zshrc" "$HOME/.zshrc"; then
  success "Shell bridge: ~/.zshrc sources macsetup"
else
  error "Shell bridge: ~/.zshrc does not source macsetup"
  failures=$((failures + 1))
fi

if [ "$failures" -eq 0 ]; then
  success "Doctor passed."
else
  error "Doctor found $failures issue(s)."
  exit 1
fi
