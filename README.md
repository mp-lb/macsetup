# Macsetup

> Development has moved to [mp-lb/pc-setup](https://github.com/mp-lb/pc-setup).
> Use that repository for new installs and changes. This repository is retained
> as a historical copy.

Macsetup is the MAP Lab host bootstrapper for programming Macs. It owns the
small layer below project development:

- Homebrew and Homebrew-managed host tools
- mise for runtime/tool versions
- Claude Code CLI and workspace trust
- Forum (`fm`), Berth (`berth`), and Zapper (`zap`) CLI installation
- GitHub authentication and Git credential helper setup
- shell bridge files
- MAP Lab AWS SSO config
- global Codex and Claude Code skills

It does not directly manage Node, Python, or Ruby with `nvm`, `pyenv`, or
`rbenv` anymore. Those belong to mise.

## Install

```
/bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/mp-lb/macsetup/main/start.sh)"
```

The install script assumes you're running it as the admin user on the machine. If the repository already exists at `~/Work/macsetup`, the script will reuse it instead of cloning again.

Set `MACSETUP_WORKSPACE` to use a different Work folder, and optionally
`MACSETUP_REPO_PATH` to place this checkout elsewhere. Both paths are saved in the
shell bridge for future terminals. For example:

```sh
export MACSETUP_WORKSPACE="$HOME/Development"
/bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/mp-lb/macsetup/main/start.sh)"
```

Setup installs Claude Code through Homebrew and records trust for the resolved
workspace path in `~/.claude.json` (or `$CLAUDE_CONFIG_DIR/.claude.json`). Existing
settings are preserved. Close Claude Code before rerunning setup so it does not
overwrite the updated config. Claude Code can still ask for separate trust for Git
repositories beneath the workspace; see its [workspace trust rules](https://code.claude.com/docs/en/permissions#project-allow-rules-and-workspace-trust).

GitHub login is checked on every run, including when reusing a checkout, followed
by `gh auth setup-git --hostname github.com`. Forum, Berth, and Zapper are installed
from their published npm packages under the mise-managed Node runtime. Berth uses
the production `@mp-lb/berth` package, never a development checkout link.

## Doctor

```
~/Work/macsetup/doctor.sh
```

## Inventory

```
~/Work/macsetup/inventory.sh
```

## Optional Apps

Large app/cask installs are intentionally outside the default bootstrap path.
Install them when needed:

```
brew bundle --file ~/Work/macsetup/Brewfile.apps
```

## Agent Skills

Global agent skills are declared in `config/global-skills.txt` and installed for Codex
and Claude Code:

```
~/Work/macsetup/bin/install-skills
```

## Uninstall Legacy Runtime State

```
~/Work/macsetup/uninstall.sh
```

This removes legacy macsetup-managed runtime directories such as `~/.nvm`,
`~/.pyenv`, `~/.rbenv`, and the old `~/google-cloud-sdk` installer. It does not
delete `~/Work`, Homebrew, git config, gh auth, or project files.

To also clear mise-managed runtime state:

```
~/Work/macsetup/uninstall.sh --all
```
