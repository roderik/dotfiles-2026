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
  fnm env --shell zsh --use-on-cd >| "$FNM_CACHE"
fi
source "$FNM_CACHE"

# ──────────────────────────────────────────────────────────────────────────────
# Zoxide (cached)
# ──────────────────────────────────────────────────────────────────────────────
ZOXIDE_CACHE="$ZSH_CACHE_DIR/zoxide.zsh"
if [[ ! -f "$ZOXIDE_CACHE" || "/opt/homebrew/bin/zoxide" -nt "$ZOXIDE_CACHE" ]]; then
  zoxide init zsh >| "$ZOXIDE_CACHE"
fi
source "$ZOXIDE_CACHE"

# ──────────────────────────────────────────────────────────────────────────────
# Atuin (cached) - must be after fzf to override Ctrl+R
# ──────────────────────────────────────────────────────────────────────────────
ATUIN_CACHE="$ZSH_CACHE_DIR/atuin.zsh"
if [[ ! -f "$ATUIN_CACHE" || "/opt/homebrew/bin/atuin" -nt "$ATUIN_CACHE" ]]; then
  atuin init zsh --disable-up-arrow >| "$ATUIN_CACHE"
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
# zmx — session persistence for terminal processes
# ──────────────────────────────────────────────────────────────────────────────
zm() {
  if [[ -n "$ZMX_SESSION" ]]; then
    echo "Already in zmx session: $ZMX_SESSION"
    return 0
  fi
  local name="${1:-default}"
  shift 2>/dev/null
  zmx attach "$name" "$@"
}
alias zml='zmx list'
alias zmk='zmx kill'
alias zmh='zmx history'

# ──────────────────────────────────────────────────────────────────────────────
# Claude Code — wrapped in zmx for session persistence
# ──────────────────────────────────────────────────────────────────────────────
claude() {
  if [[ -n "$ZMX_SESSION" ]]; then
    command claude --dangerously-skip-permissions "$@"
    return
  fi
  local git_root name
  git_root=$(git rev-parse --show-toplevel 2>/dev/null)
  name="claude-${${git_root:+${git_root:t}}:-${PWD:t}}"
  zmx attach "$name" command claude --dangerously-skip-permissions "$@"
}
alias c='claude'

# ──────────────────────────────────────────────────────────────────────────────
# Codex — wrapped in zmx for session persistence
# ──────────────────────────────────────────────────────────────────────────────
codex() {
  if [[ -n "$ZMX_SESSION" ]]; then
    command codex "$@"
    return
  fi
  local git_root name
  git_root=$(git rev-parse --show-toplevel 2>/dev/null)
  name="codex-${${git_root:+${git_root:t}}:-${PWD:t}}"
  zmx attach "$name" command codex "$@"
}
alias x='codex'

wtc() {
  git fetch origin main && wt switch --create --base origin/main && claude
}

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
  git fetch origin main && wt switch "pr:$pr" && claude
}

# Create a stacked worktree: wts [branch-name]
# Selects parent via fzf, creates worktree with wt, registers stack with git-town, launches claude
wts() {
  local branch_name="$1"
  local current_branch
  current_branch=$(git branch --show-current 2>/dev/null)

  # Pick parent: current branch (default) or choose from list
  local parent
  parent=$(printf '%s\n%s' "$current_branch (current)" "Pick from list..." | \
    fzf --header "Stack on which parent?" --height=5 --no-preview)
  [[ -z "$parent" ]] && { echo "No parent selected"; return 1; }

  if [[ "$parent" == "Pick from list..." ]]; then
    parent=$({ git branch --format='%(refname:short)'; git branch -r --format='%(refname:short)' | sed 's|^origin/||'; } | sort -u | grep -v '^HEAD$' | \
      fzf --header "Select parent branch" \
          --preview 'git log --oneline --graph -10 {}' \
          --preview-window=right:50%)
    [[ -z "$parent" ]] && { echo "No branch selected"; return 1; }
  else
    parent="$current_branch"
  fi

  # Prompt for branch name if not provided
  if [[ -z "$branch_name" ]]; then
    echo -n "New branch name: "; read branch_name
    [[ -z "$branch_name" ]] && { echo "No branch name"; return 1; }
  fi

  # Create worktree based on parent
  git fetch origin main
  wt switch --create "$branch_name" --base "$parent"

  # Register stacked parent with git-town (must happen before claude launches)
  git-town set-parent "$parent"

  # Launch Claude in the new worktree
  claude
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
  [[ ! -f "$comp_dir/_git-town" ]] && git-town completions zsh > "$comp_dir/_git-town" 2>/dev/null
  [[ ! -f "$comp_dir/_zmx" ]]      && zmx completions zsh > "$comp_dir/_zmx" 2>/dev/null
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
  [[ -n "$ZMX_SESSION" ]] && title="[$ZMX_SESSION] $title"
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

# ──────────────────────────────────────────────────────────────────────────────
# Zellij - attach or create session via `zj`
# ──────────────────────────────────────────────────────────────────────────────
zj() {
  if [[ -n "$ZELLIJ" ]]; then
    return 0
  fi
  zellij attach -c "$@"
}

# Entire CLI shell completion
autoload -Uz compinit && compinit && source <(entire completion zsh)
