# Python Tooling (uv instead of pip)

Omarchy does not ship `pip` or `uv`. Python itself is only present as a dependency of base packages such as `python-gobject`, `udiskie` and `yt-dlp`. This setup uses `uv` as the single Python entry point and removes system `pip`.

Historically `python-pip` was in `additional-packages.conf` because Neovim's Mason plugin needed it to install `pylsp` (python-lsp-server). Mason has since moved to `basedpyright`, which does not need system pip, so pip is dropped.

## Apply on a new or existing machine

1. Pull both repos. The dotfiles setup only runs `chezmoi apply`, it does not pull, so `~/.dotfiles` must be updated first:
```bash
git -C ~/.dotfiles pull
cd ~/dev/crucible-omarchy && git pull
```

2. Run the installer and pick option 3 (install additional packages) and then option 5 (setup dotfiles). That installs `uv` and applies the alias change:
```bash
./run.sh
```
   Or do the same by hand:
```bash
sudo pacman -S --needed uv
chezmoi apply -v
```

3. Remove system pip. Nothing on the machine uses it once Mason has switched to basedpyright:
```bash
sudo pacman -Rns python-pip
```

4. Update the Neovim Mason config. `~/.config/nvim` is not managed by the dotfiles, so edit it directly. In `~/.config/nvim/plugin/mason.lua` replace `"pylsp"` with `"basedpyright"` in the `ensure_installed` list.

5. Swap the language server in Mason. Open Neovim and run:
```
:MasonUninstall python-lsp-server
:MasonInstall basedpyright
```
   The `ensure_installed` entry will also install basedpyright automatically on the next Neovim start, so the second command is optional.

6. Reload the shell so the old `npm=pnpm` alias is gone:
```bash
exec zsh
```

## Verify

```bash
pacman -Q uv python-pip        # uv listed, python-pip "was not found"
alias npm                       # prints nothing
command -v npm                  # mise's node install, not pnpm
~/.local/share/nvim/mason/bin/basedpyright-langserver --version
```

## Notes

- **Mason still works without system pip.** Mason installs pypi packages into a venv created with Python's stdlib `venv` module. The pip inside that venv comes from `ensurepip`, which is part of Arch's `python` package, not `python-pip`.
- **basedpyright is a pypi package in the Mason registry**, not npm. It ships its own Node runtime inside the venv, so it depends on neither system pip nor mise's node.
- **The npm alias was removed on purpose.** Mason calls the `npm` binary directly and never sees shell aliases, but the alias got in the way interactively. The `npm` package in `DEV_TOOLS_LANGUAGES` and mise's node both provide a real `npm`.
- **Use uv for Python projects and ad hoc tools**, for example `uv python install 3.13`, `uv tool install ruff`, or `uvx <tool>`. Avoid `pip install --user`; there is no pip to do it with.
- Mason venvs are tied to the Python minor version. After a `python` major upgrade from pacman, reinstall basedpyright via `:MasonInstall basedpyright`.
