export PATH="$HOME/.local/bin:$PATH"
setopt autocd

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

# Guard against double-init on re-source (use `exec zsh` for full reload)
if (( ! ${+ZIM_LOADED} )); then
  source ${ZIM_HOME}/init.zsh
  ZIM_LOADED=1
fi

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

export EDITOR=nvim
export VISUAL=nvim
export HOMEBREW_NO_ENV_HINTS=1
export PATH=/opt/homebrew/share/google-cloud-sdk/bin:"$PATH"

# ──────────────────────────────────────────────────────────────────────────────
# FZF - use fd for faster file finding and bat for preview
# ──────────────────────────────────────────────────────────────────────────────
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
# Use tmux popup for fzf when inside tmux
if [[ -n "$TMUX" ]]; then
  export FZF_TMUX_OPTS="-p 80%,60%"
  export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} --tmux center,80%,60%"
fi

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
# Eza - modern ls with git integration
# ──────────────────────────────────────────────────────────────────────────────
alias ls='eza'
alias ll='eza -l --git --icons'
alias la='eza -la --git --icons'
alias lt='eza --tree --level=2 --icons'

# ──────────────────────────────────────────────────────────────────────────────
# Neovim
# ──────────────────────────────────────────────────────────────────────────────
alias vim='nvim'
alias vi='nvim'


# ──────────────────────────────────────────────────────────────────────────────
# Zellij - attach or create session named after current directory
# ──────────────────────────────────────────────────────────────────────────────
zj() {
  local session_name="${${PWD##*/}//./_}"
  zellij attach "$session_name" 2>/dev/null || zellij --session "$session_name"
}

zl() {
  local session
  session=$(zellij ls -s 2>/dev/null | fzf --height=40% --reverse) || return
  zellij attach "$session"
}

zk() {
  zellij delete-session "${${PWD##*/}//./_}" 2>/dev/null
  zellij kill-session "${${PWD##*/}//./_}" 2>/dev/null
}

alias zka='zellij delete-all-sessions -y'

alias claude='claude --dangerously-skip-permissions'
alias c='claude'
alias x='codex'
alias oc='opencode'

# Resolve the main worktree root — from inside a repo or via fzf picker
__wt_repo_root() {
  local root
  root=$(git worktree list --porcelain 2>/dev/null | head -1 | sed 's/^worktree //')
  if [[ -n "$root" ]]; then
    echo "$root"; return
  fi
  root=$(for d in ~/Development/*/; do [[ -d "$d/.git" ]] && echo "${d%/}"; done | sort | \
    fzf --height=40% --reverse --header "Select repo" --with-nth=-1 --delimiter=/)
  [[ -n "$root" ]] && echo "$root"
}

# List worktrees and cd to selection
wtl() {
  local repo_root
  repo_root=$(__wt_repo_root) || return
  [[ -z "$repo_root" ]] && return

  local target
  target=$(git -C "$repo_root" worktree list | \
    fzf --height=40% --reverse --header "Select worktree" | awk '{print $1}')
  [[ -z "$target" ]] && return

  cd "$target"
}

# Create a new worktree (works from anywhere)
wtc() {
  local repo_root
  repo_root=$(__wt_repo_root) || return
  [[ -z "$repo_root" ]] && return

  cd "$repo_root" && git fetch origin main && wt switch --create --base origin/main "$@"
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

# Pick a PR from fzf and check it out as a worktree
wtg() {
  local repo_root
  repo_root=$(__wt_repo_root) || return
  [[ -z "$repo_root" ]] && return

  local pr
  if [[ -n "$1" ]]; then
    pr="$1"
  else
    pr=$(cd "$repo_root" && gh pr list --state open --limit 50 \
      --json number,title,author,headRefName \
      --template '{{range .}}#{{.number}}	{{.title}} ({{.author.login}}) [{{.headRefName}}]{{"\n"}}{{end}}' | \
      fzf --height=40% --reverse --header "Select PR" | awk -F'\t' '{print $1}' | tr -d '#')
  fi
  [[ -z "$pr" ]] && return

  cd "$repo_root" && git fetch origin main && wt switch "pr:$pr" && zic
}

# Delete a worktree via fzf picker
wtd() {
  local repo_root
  repo_root=$(__wt_repo_root) || return
  [[ -z "$repo_root" ]] && return

  local target
  target=$(git -C "$repo_root" worktree list | tail -n +2 | \
    fzf --height=40% --reverse --header "Delete which worktree?" | awk '{print $1}')
  [[ -z "$target" ]] && return

  local branch
  branch=$(git -C "$repo_root" worktree list | grep "^$target " | awk '{print $3}' | tr -d '[]')

  echo "Removing worktree: $branch ($target)"
  wt -C "$repo_root" remove --yes --foreground "$branch"
}

# Create a stacked worktree: wts [branch-name]
# Selects parent via fzf, creates worktree with wt, registers stack with git-town
wts() {
  local branch_name="$1"
  local current_branch
  current_branch=$(git branch --show-current 2>/dev/null)

  local repo_root
  repo_root=$(__wt_repo_root) || return
  [[ -z "$repo_root" ]] && return
  cd "$repo_root" || return

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

  # Register stacked parent with git-town
  git-town set-parent "$parent"
}

# Set parent branch for git-town via fzf picker
gtp() {
  local parent
  parent=$({ git branch --format='%(refname:short)'; git branch -r --format='%(refname:short)' | sed 's|^origin/||'; } | sort -u | grep -v '^HEAD$' | \
    fzf --header "Select parent branch" \
        --preview 'git log --oneline --graph -10 {}' \
        --preview-window=right:50%)
  [[ -z "$parent" ]] && return

  git-town set-parent "$parent"
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

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi



# >>> DALP EXA 1PASSWORD >>>
if [ -f "/Users/roderik/.local/state/dalp/exa-mcp.zsh" ]; then
  source "/Users/roderik/.local/state/dalp/exa-mcp.zsh"
fi
# <<< DALP EXA 1PASSWORD <<<

# bun completions
[ -s "/Users/roderik/.bun/_bun" ] && source "/Users/roderik/.bun/_bun"
