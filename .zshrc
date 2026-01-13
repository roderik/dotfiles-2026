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

# ──────────────────────────────────────────────────────────────────────────────
# VCS Info (jj + git aware prompt)
# ──────────────────────────────────────────────────────────────────────────────
_vcs_info() {
  typeset -gA git_info
  git_info=()

  # Check for jj repository first (jj can coexist with git)
  local jj_root
  jj_root=$(jj root 2>/dev/null)

  if [[ -n "$jj_root" ]]; then
    # We're in a jj repository
    local jj_output
    jj_output=$(jj log -r @ --no-graph -T '
      separate(" ",
        change_id.shortest(8),
        if(bookmarks, bookmarks.join(" ")),
        if(conflict, "conflict"),
        if(empty, "empty"),
        if(immutable, "immutable")
      )
    ' 2>/dev/null)

    if [[ -n "$jj_output" ]]; then
      local change_id="${jj_output%% *}"
      local rest="${jj_output#* }"
      local status_parts=()
      local bookmark=""

      # Parse the output
      for word in ${=rest}; do
        case "$word" in
          conflict) status_parts+=("!") ;;
          empty) status_parts+=("∅") ;;
          immutable) status_parts+=("⊘") ;;
          *) [[ -z "$bookmark" ]] && bookmark="$word" ;;
        esac
      done

      local status_str=""
      [[ ${#status_parts[@]} -gt 0 ]] && status_str=" %F{red}[${(j::)status_parts}]%f"

      if [[ -n "$bookmark" ]]; then
        git_info[prompt]=" on %B%F{blue}${bookmark}%f%b %F{green}(${change_id})%f${status_str}"
      else
        git_info[prompt]=" on %B%F{blue}${change_id}%f%b${status_str}"
      fi
    fi
  elif git rev-parse --is-inside-work-tree &>/dev/null; then
    # Fall back to git-info for pure git repos
    git-info
  fi
}

# Replace git-info hook with our vcs-info
add-zsh-hook -d precmd git-info 2>/dev/null
add-zsh-hook precmd _vcs_info

# qlty completions
[ -s "/opt/homebrew/share/zsh/site-functions/_qlty" ] && source "/opt/homebrew/share/zsh/site-functions/_qlty"

# qlty
export QLTY_INSTALL="$HOME/.qlty"
export PATH="/Users/roderik/.foundry/bin/:$QLTY_INSTALL/bin:$PATH"



alias claude-mem='bun "/Users/roderik/.claude/plugins/marketplaces/thedotmack/plugin/scripts/worker-service.cjs"'

# zkstack completion
source "/Users/roderik/.zsh/completion/_zkstack.zsh"

# Added by git-ai installer on Mon Jan 12 22:49:21 CET 2026
export PATH="/Users/roderik/.git-ai/bin:$PATH"
