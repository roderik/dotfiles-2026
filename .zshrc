export HOMEBREW_NO_ENV_HINTS=1

export PATH="$HOME/.local/bin:$PATH"

# bun completions
[ -s "/Users/roderik/.bun/_bun" ] && source "/Users/roderik/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi

# Added by git-ai installer on Sat Mar  7 20:01:29 CET 2026
export PATH="/Users/roderik/.git-ai/bin:$PATH"

# cubic
export PATH="/Users/roderik/.cubic/bin":$PATH

# opencode
export PATH="/Users/roderik/.opencode/bin:$PATH"

# >>> DALP EXA 1PASSWORD >>>
if [ -f "/Users/roderik/.local/state/dalp/exa-mcp.zsh" ]; then
  source "/Users/roderik/.local/state/dalp/exa-mcp.zsh"
fi
# <<< DALP EXA 1PASSWORD <<<

alias claude-mem='bun "/Users/roderik/.claude/plugins/cache/thedotmack/claude-mem/10.5.2/scripts/worker-service.cjs"'

# ByteRover CLI
export PATH="$HOME/.brv-cli/bin:$PATH"
