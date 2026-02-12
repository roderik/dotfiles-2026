# Fish Shell Config

Fish equivalent of the zsh config in `.zshrc`. Includes fnm, zoxide, atuin, fzf, bat, and worktree helper functions (`wtr`, `wtg`, `wts`, `wt-cleanup`, `zj`).

## Install

```bash
brew install fish
```

Symlink the config and functions into your existing Fish setup:

```bash
ln -sf ~/Development/dotfiles-2026/.config/fish/config.fish ~/.config/fish/config.fish
ln -sf ~/Development/dotfiles-2026/.config/fish/functions/*.fish ~/.config/fish/functions/
```

> **Note:** Don't symlink the entire `~/.config/fish` directory if you already have one — it will nest instead of replace. Symlink individual files to merge with your existing Fish plugins and config.

## Verify

```bash
fish -c 'type wts'
```
