# Repository Guidelines

## Project Structure & Module Organization

- `script/init.sh` – bootstraps the environment; ensures `uv` and `ansible` are available, then runs `ansible-playbook init.yaml`.
- `init.yaml` – main Ansible play that orchestrates install and configure steps.
- `task/install/` – per‑OS installers:
  - `darwin/base.yaml` uses Homebrew packages.
  - `linux/*.yaml` download tarballs and symlink binaries into `~/.local/bin`.
- `task/configure/` – creates symlinks and templates for `shell`, `git`, `ghostty`, `k9s`, `zed`, and `nvim`.
- `config/` – actual dotfiles and app configs: `.profile`, `.rc`, `.rc.d/*`, plus `nvim/`, `zed/`, `ghostty/`, `k9s/`, `git/`.

## Build, Test, and Development Commands

- Bootstrap everything: `bash script/init.sh`
- Install only: `ansible-playbook init.yaml --tags install`
- Configure only: `ansible-playbook init.yaml --tags configure`
- Dry‑run with diffs: `ansible-playbook init.yaml --check --diff`
- Optional overrides: export `XDG_CONFIG_HOME`, `XDG_DATA_HOME`, `LOCAL_BINARY_HOME` (the script exports safe defaults).

## Coding Style & Naming Conventions

- YAML: 2‑space indent, idempotent tasks, descriptive names; group logic via `import_tasks`.
- Shell (bash): `set -e`, quote variables, use `local` in functions, keep commands portable.
- Lua (Neovim): keep plugin specs in `config/nvim/lua/plugins/*.lua` and config in `config/nvim/lua/config/*`.
- Naming: match file to tool/app (e.g., `task/install/linux/ripgrep.yaml`, `task/configure/git.yaml`).

## Testing Guidelines

- Validate changes with Ansible: `--check` + `--diff`.
- Verify symlinks after configure (examples): `ls -l ~/.zshrc`, `ls -l ~/.config/nvim`, `cat ~/.config/git/config`.
- Sanity‑check binaries: `nvim --version`, `gh --version`, `rg --version`.
- For Neovim, launch once to ensure Lazy.nvim installs plugins correctly.

## Commit & Pull Request Guidelines

- Commits: imperative mood with scope when helpful (e.g., `install: add fzf`, `configure: zed keymap tweaks`).
- PRs: include OS tested (Linux/macOS), summary of changes, commands used, and screenshots for UI changes (e.g., Ghostty, Zed).
- Update `README.md` or tasks when behavior changes (new packages, paths, or tags).

## Security & Configuration Tips

- Do not commit secrets. Git config uses SSH signing; ensure `~/.ssh/id_ed25519.pub` or adjust `config/git/.gitconfig.j2`.
- Prefer templating or env‑backed values for user‑specific paths; keep tasks idempotent and safe to re‑run.
