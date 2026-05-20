## Philosophy

This setup follows a **system-level tools, project-level environments** approach:

- **System level**: `pyenv`, `poetry`, and `uv` are installed globally. Python versions are managed by `pyenv` and stored in `~/.pyenv`, and `poetry` is installed via `uv tool install`. Both `poetry` and `uv` are available as package managers.
- **Project level**: Each project has its own self-contained `.venv` directory containing the Python interpreter and all dependencies. Everything needed for the project lives in the project folder.

## System Setup

Python versions are managed by `pyenv` and stored in `~/.pyenv`. The install script sets up the latest stable Python 3 version as the default. To install additional versions:

```
pyenv install 3.12.7
pyenv global 3.12.7
```

## Project Setup

Each project gets its own self-contained `.venv` directory. Both `uv` and `poetry` are installed and can be used. Choose the one that fits your workflow.

### Using Poetry

```
cd myproject
pyenv local $(pyenv version | cut -d' ' -f1)
poetry init -n
poetry env use python
poetry install
```

This creates:
- `.python-version` file (pins the Python version via pyenv)
- `.venv/` directory (contains Python interpreter and all dependencies)
- `pyproject.toml` (project configuration and dependencies)

### Using uv

```
cd myproject
pyenv local $(pyenv version | cut -d' ' -f1)
uv init
uv sync
```

This creates:
- `.python-version` file (pins the Python version via pyenv)
- `.venv/` directory (contains Python interpreter and all dependencies)
- `pyproject.toml` (project configuration and dependencies)
- `uv.lock` (lock file for reproducible installs)

Everything is self-contained in the project directory. When you clone a repo, running `poetry install` or `uv sync` will recreate the `.venv` with the correct Python version and dependencies.

## Adding Dependencies

### Using Poetry

Set up project tooling:
```
poetry add --group dev black ruff pyright pytest
```

### Using uv

Set up project tooling:
```
uv add --dev black ruff pyright pytest
```

## Running Code

### Using Poetry

Run code with poetry (uses the project's `.venv`):
```
poetry run python script.py
```

### Using uv

Run code with uv (uses the project's `.venv`):
```
uv run python script.py
```

## Editor Configuration

### VSCode Extensions
- ms-python.python
- ms-python.vscode-pylance
- charliermarsh.ruff
- ms-python.black-formatter

### VSCode Settings

Add to `.vscode/settings.json` in each project:
```
{
  "python.defaultInterpreterPath": "${workspaceFolder}/.venv/bin/python",
}
```
