export PATH="$HOME/.local/bin:$PATH"

# ──────────────────────────────────────────────────────────────────────────────
# Completion cache directory (must be before zimfw init)
# ──────────────────────────────────────────────────────────────────────────────
ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
[[ -d "$ZSH_CACHE_DIR/completions" ]] || mkdir -p "$ZSH_CACHE_DIR/completions"
fpath=("$ZSH_CACHE_DIR/completions" $fpath)

# ──────────────────────────────────────────────────────────────────────────────
# Zimfw
# ──────────────────────────────────────────────────────────────────────────────
ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim

if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
  source /opt/homebrew/opt/zimfw/share/zimfw.zsh init
fi

source ${ZIM_HOME}/init.zsh

# ──────────────────────────────────────────────────────────────────────────────
# Bun
# ──────────────────────────────────────────────────────────────────────────────
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# ──────────────────────────────────────────────────────────────────────────────
# Fnm (cached)
# ──────────────────────────────────────────────────────────────────────────────
FNM_CACHE="$ZSH_CACHE_DIR/fnm.zsh"
if [[ ! -f "$FNM_CACHE" || "/opt/homebrew/bin/fnm" -nt "$FNM_CACHE" ]]; then
  fnm env --shell zsh --use-on-cd > "$FNM_CACHE"
fi
source "$FNM_CACHE"

# ──────────────────────────────────────────────────────────────────────────────
# Zoxide (cached)
# ──────────────────────────────────────────────────────────────────────────────
ZOXIDE_CACHE="$ZSH_CACHE_DIR/zoxide.zsh"
if [[ ! -f "$ZOXIDE_CACHE" || "/opt/homebrew/bin/zoxide" -nt "$ZOXIDE_CACHE" ]]; then
  zoxide init zsh > "$ZOXIDE_CACHE"
fi
source "$ZOXIDE_CACHE"

export HOMEBREW_NO_ENV_HINTS=1
export PATH=/opt/homebrew/share/google-cloud-sdk/bin:"$PATH"

# ──────────────────────────────────────────────────────────────────────────────
# FZF - use fd for faster file finding and bat for preview
# ──────────────────────────────────────────────────────────────────────────────
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"

# ──────────────────────────────────────────────────────────────────────────────
# Bat - better cat with syntax highlighting
# ──────────────────────────────────────────────────────────────────────────────
export BAT_THEME="ansi"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
alias cat='bat --paging=never'

# ──────────────────────────────────────────────────────────────────────────────
# Procs - modern ps replacement
# ──────────────────────────────────────────────────────────────────────────────
alias ps='procs'

# Claude Code
alias claude='claude --dangerously-skip-permissions --chrome'
alias c='claude'

# ──────────────────────────────────────────────────────────────────────────────
# Tool completions (cached to fpath)
# ──────────────────────────────────────────────────────────────────────────────
# Regenerate with: rm -rf ~/.cache/zsh/completions && exec zsh
() {
  local comp_dir="$ZSH_CACHE_DIR/completions"
  local regen=0

  # Check if any completion needs regeneration
  [[ ! -f "$comp_dir/_gh" ]]      && gh completion -s zsh > "$comp_dir/_gh" 2>/dev/null
  [[ ! -f "$comp_dir/_helm" ]]    && helm completion zsh > "$comp_dir/_helm" 2>/dev/null
  [[ ! -f "$comp_dir/_kubectl" ]] && kubectl completion zsh > "$comp_dir/_kubectl" 2>/dev/null
  [[ ! -f "$comp_dir/_op" ]]      && op completion zsh > "$comp_dir/_op" 2>/dev/null
  :
}

# ──────────────────────────────────────────────────────────────────────────────
# Terminal Title (git root or current directory)
# ──────────────────────────────────────────────────────────────────────────────
_set_terminal_title() {
  local title
  local git_root
  git_root=$(git rev-parse --show-toplevel 2>/dev/null)
  if [[ -n "$git_root" ]]; then
    title="${git_root:t}"
  else
    title="${PWD:t}"
  fi
  print -Pn "\e]0;${title}\a"
}
add-zsh-hook precmd _set_terminal_title
