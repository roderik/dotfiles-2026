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

# ──────────────────────────────────────────────────────────────────────────────
# Atuin (cached) - must be after fzf to override Ctrl+R
# ──────────────────────────────────────────────────────────────────────────────
ATUIN_CACHE="$ZSH_CACHE_DIR/atuin.zsh"
if [[ ! -f "$ATUIN_CACHE" || "/opt/homebrew/bin/atuin" -nt "$ATUIN_CACHE" ]]; then
  atuin init zsh --disable-up-arrow > "$ATUIN_CACHE"
fi
source "$ATUIN_CACHE"
# Bind up arrow to full atuin search (like Ctrl-R)
bindkey '^[[A' atuin-search
bindkey '^[OA' atuin-search

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

# ──────────────────────────────────────────────────────────────────────────────
# Neovim
# ──────────────────────────────────────────────────────────────────────────────
alias vim='nvim'
alias vi='nvim'

# ──────────────────────────────────────────────────────────────────────────────
# Tmux aliases
# ──────────────────────────────────────────────────────────────────────────────
alias t='tmux'
alias tn='tmux new-session -s'          # tn myproject
alias ta='tmux attach-session -t'       # ta myproject
alias tl='tmux list-sessions'
alias tk='tmux kill-session -t'         # tk myproject
alias tka='tmux kill-server'            # kill all sessions
alias td='tmux detach'
alias tw='tmux list-windows'
alias tp='tmux list-panes'
alias ts='tmux switch-client -t'        # ts myproject (switch from inside tmux)

# ──────────────────────────────────────────────────────────────────────────────
# Claude Code (wrapped in tmux - invisible, auto-dying session)
# ──────────────────────────────────────────────────────────────────────────────
claude() {
  local dir_name="${PWD:t}"
  local session_name="${dir_name//./-}"
  if [[ -n "$TMUX" ]]; then
    command claude --dangerously-skip-permissions "$@"
  elif tmux has-session -t "$session_name" 2>/dev/null; then
    tmux attach-session -t "$session_name"
  else
    tmux new-session -s "$session_name" "command claude --dangerously-skip-permissions $*"
  fi
}
alias c='claude'
alias wtc='git fetch origin main && wt switch --create --base origin/main --execute=claude'

# Remove current worktree and return to main
wtr() {
  local current_branch
  current_branch=$(git branch --show-current 2>/dev/null)

  if [[ -z "$current_branch" ]]; then
    echo "Error: not in a git repository"
    return 1
  fi

  local main_worktree
  main_worktree=$(git worktree list --porcelain | head -1 | sed 's/^worktree //')

  if [[ "$PWD" == "$main_worktree" || "$PWD" == "$main_worktree"/* ]]; then
    echo "Error: already in the main worktree — nothing to remove"
    return 1
  fi

  echo "Removing worktree: $current_branch"
  cd "$main_worktree" || return 1
  wt remove --yes --foreground "$current_branch"
  echo "Back in main worktree: $main_worktree"
}

# Switch to a PR worktree: wtg 123 or wtg #123
wtg() {
  local pr="${1#\#}"
  if [[ -z "$pr" ]]; then
    echo "Usage: wtg <number>"
    return 1
  fi
  git fetch origin main && wt switch "pr:$pr"
}

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

# bun completions
[ -s "/Users/roderik/.bun/_bun" ] && source "/Users/roderik/.bun/_bun"

# ──────────────────────────────────────────────────────────────────────────────
# Worktrunk - worktree cleanup helper
# ──────────────────────────────────────────────────────────────────────────────
wt-cleanup() {
  local -a to_remove=()

  echo "Scanning worktrees for merged/closed PRs..."
  echo

  # Strip statusline/symbols (contain ANSI control chars) then extract candidate branches
  while IFS=$'\t' read -r branch is_main is_current detached; do
    [[ "$is_main" == "true" ]] && continue
    [[ "$is_current" == "true" ]] && continue
    [[ "$detached" == "true" ]] && continue
    [[ -z "$branch" || "$branch" == "null" || ! "$branch" =~ ^[a-zA-Z0-9] ]] && continue

    local pr_state
    pr_state=$(gh pr view "$branch" --json state 2>/dev/null | jq -r '.state // empty')

    case "$pr_state" in
      MERGED)  echo "  ✓ $branch (merged) — will remove";  to_remove+=("$branch") ;;
      CLOSED)  echo "  ✓ $branch (closed) — will remove";  to_remove+=("$branch") ;;
      OPEN)    echo "  → $branch (open) — skipping" ;;
      *)       echo "  ? $branch (no PR) — skipping" ;;
    esac
  done < <(wt list --format=json | jq -r '.[] | del(.statusline, .symbols) | [.branch // "", (.is_main | tostring), (.is_current | tostring), (.worktree.detached | tostring)] | @tsv')

  echo

  if [[ ${#to_remove[@]} -eq 0 ]]; then
    echo "Nothing to clean up."
    return 0
  fi

  echo "Removing ${#to_remove[@]} worktree(s)..."
  wt remove --yes --foreground "${to_remove[@]}"
  echo "Done."
}

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi
