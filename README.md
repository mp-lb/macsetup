# Macsetup

Macsetup is the MAP Lab host bootstrapper for programming Macs. It owns the
small layer below project development:

- Homebrew and Homebrew-managed host tools
- mise for runtime/tool versions
- Zapper CLI installation
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

Global agent skills are declared in `skills/global.txt` and installed for Codex
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
