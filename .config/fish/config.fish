# ──────────────────────────────────────────────────────────────────────────────
# OrbStack
# ──────────────────────────────────────────────────────────────────────────────
source ~/.orbstack/shell/init.fish 2>/dev/null; or true

# ──────────────────────────────────────────────────────────────────────────────
# Bat
# ──────────────────────────────────────────────────────────────────────────────
set -gx BAT_THEME ansi
set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"

# ──────────────────────────────────────────────────────────────────────────────
# Atuin - bind up arrow to full search (like Ctrl-R)
# ──────────────────────────────────────────────────────────────────────────────
bind \e\[A _atuin_search
bind \eOA _atuin_search

# ──────────────────────────────────────────────────────────────────────────────
# Aliases (additions to conf.d/10-aliases.fish)
# ──────────────────────────────────────────────────────────────────────────────
alias vim='nvim'
alias vi='nvim'
alias claude='command claude --dangerously-skip-permissions'
alias c='claude'
alias x='codex'
alias ps='procs'
alias wtc='git fetch origin main && wt switch --create --base origin/main --execute=claude'

# ──────────────────────────────────────────────────────────────────────────────
# Worktrunk
# ──────────────────────────────────────────────────────────────────────────────
if command -q wt
    wt config shell init fish | source
end
