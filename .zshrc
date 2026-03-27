export HOMEBREW_NO_ENV_HINTS=1

export PATH="$HOME/.local/bin:$PATH"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi

export PATH="$HOME/.git-ai/bin:$PATH"
export PATH="$HOME/.cubic/bin:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"
export PATH="$HOME/.foundry/bin:$PATH"
export PATH="$HOME/.brv-cli/bin:$PATH"

# >>> DALP EXA 1PASSWORD >>>
if [ -f "$HOME/.local/state/dalp/exa-mcp.zsh" ]; then
  source "$HOME/.local/state/dalp/exa-mcp.zsh"
fi
# <<< DALP EXA 1PASSWORD <<<

alias claude-mem='bun "$HOME/.claude/plugins/cache/thedotmack/claude-mem/10.5.2/scripts/worker-service.cjs"'
