# Fish Shell Config

Fish equivalent of the zsh config in `.zshrc`. Includes fnm, zoxide, atuin, fzf, bat, and worktree helper functions (`wtr`, `wtg`, `wts`, `wt-cleanup`, `zj`).

## Install

```bash
brew install fish
cd /path/to/dotfiles-2026/.config/fish
mkdir -p ~/.config/fish/functions
ln -sf "$(pwd)/config.fish" ~/.config/fish/config.fish
ln -sf "$(pwd)"/functions/*.fish ~/.config/fish/functions/
```
