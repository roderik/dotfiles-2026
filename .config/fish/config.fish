# ──────────────────────────────────────────────────────────────────────────────
# PATH
# ──────────────────────────────────────────────────────────────────────────────
fish_add_path -g $HOME/.local/bin

# ──────────────────────────────────────────────────────────────────────────────
# Homebrew
# ──────────────────────────────────────────────────────────────────────────────
eval (/opt/homebrew/bin/brew shellenv)

# OrbStack
source ~/.orbstack/shell/init.fish 2>/dev/null; or true

# ──────────────────────────────────────────────────────────────────────────────
# Bun
# ──────────────────────────────────────────────────────────────────────────────
set -gx BUN_INSTALL $HOME/.bun
fish_add_path -g $BUN_INSTALL/bin

# ──────────────────────────────────────────────────────────────────────────────
# Fnm
# ──────────────────────────────────────────────────────────────────────────────
fnm env --shell fish --use-on-cd | source

# ──────────────────────────────────────────────────────────────────────────────
# Zoxide
# ──────────────────────────────────────────────────────────────────────────────
zoxide init fish | source

# ──────────────────────────────────────────────────────────────────────────────
# Atuin - must be after fzf to override Ctrl+R
# ──────────────────────────────────────────────────────────────────────────────
atuin init fish --disable-up-arrow | source
# Bind up arrow to full atuin search (like Ctrl-R)
bind \e\[A _atuin_search
bind \eOA _atuin_search

# ──────────────────────────────────────────────────────────────────────────────
# Environment variables
# ──────────────────────────────────────────────────────────────────────────────
set -gx HOMEBREW_NO_ENV_HINTS 1
fish_add_path -g /opt/homebrew/share/google-cloud-sdk/bin

# ──────────────────────────────────────────────────────────────────────────────
# FZF - use fd for faster file finding and bat for preview
# ──────────────────────────────────────────────────────────────────────────────
set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
set -gx FZF_ALT_C_COMMAND 'fd --type d --hidden --follow --exclude .git'
set -gx FZF_CTRL_T_OPTS "--preview 'bat --color=always --style=numbers --line-range=:500 {}'"

# ──────────────────────────────────────────────────────────────────────────────
# Bat - better cat with syntax highlighting
# ──────────────────────────────────────────────────────────────────────────────
set -gx BAT_THEME ansi
set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"

# ──────────────────────────────────────────────────────────────────────────────
# Aliases
# ──────────────────────────────────────────────────────────────────────────────
alias cat='bat --paging=never'
alias ps='procs'
alias vim='nvim'
alias vi='nvim'
alias claude='command claude --dangerously-skip-permissions'
alias c='claude'
alias x='codex'
alias wtc='git fetch origin main && wt switch --create --base origin/main --execute=claude'

# ──────────────────────────────────────────────────────────────────────────────
# Worktrunk
# ──────────────────────────────────────────────────────────────────────────────
if command -q wt
    wt config shell init fish | source
end

# ──────────────────────────────────────────────────────────────────────────────
# Entire CLI shell completion
# ──────────────────────────────────────────────────────────────────────────────
if command -q entire
    entire completion fish | source
end
