# Macsetup

This repository bootstraps MAP Lab programming Macs.

## Boundary

Macsetup owns only the host substrate:

- Homebrew and Homebrew-managed CLI tools
- mise installation and global default tools
- the Zapper CLI install
- the shell bridge that activates mise and adds MAP Lab helper scripts to PATH
- doctor/inventory scripts for checking local machine state

Macsetup does not directly install language runtimes with `nvm`, `pyenv`, or
`rbenv`. Runtime versions belong to mise. Project services, ports, env files,
and tasks belong to Zapper.

## Structure

- `Brewfile` is the required host-tool declaration.
- `Brewfile.apps` is optional large app/cask installs.
- `Brewfile.cloud` is optional cloud CLI installs.
- `start.sh` is the bootstrap entrypoint and must remain runnable from the
  GitHub raw URL.
- `uninstall.sh` removes legacy macsetup-managed runtime state only; it must
  never delete `~/Code`, project files, git config, or Homebrew.
- `doctor.sh` checks whether the required host substrate is healthy.
- `inventory.sh` prints what is installed.
- `env/` contains shell configuration.
- `bin/` contains small MAP Lab helper commands.

## Editing Rules

Keep the repo boring. Prefer deleting stale setup code over preserving historical
layers.

When adding a tool:

1. Put required host CLI tools in `Brewfile`.
2. Put optional heavy apps in `Brewfile.apps`.
3. Put optional cloud CLIs in `Brewfile.cloud`.
4. Put language/runtime/tool versions in mise, not shell scripts.
5. Add or update doctor/inventory checks when useful.

Before finishing, run:

```bash
zsh -n start.sh uninstall.sh doctor.sh inventory.sh env/zshrc
brew bundle check --file ./Brewfile
./doctor.sh
```
