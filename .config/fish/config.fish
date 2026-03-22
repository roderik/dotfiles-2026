/opt/homebrew/bin/brew shellenv | source

if status is-interactive
  touch ~/.hushlogin
  set -U fish_greeting

  set -gx HOMEBREW_NO_ENV_HINTS 1
  set -gx BAT_THEME Vesper
  set -gx EZA_COLORS 'di=1;37:fi=0;37:ln=36:ex=38;2;255;199;153:sn=38;2;160;160;160:sb=38;2;160;160;160:uu=38;2;160;160;160:da=38;2;139;139;139:ga=38;2;153;255;228:gm=38;2;255;199;153:gd=38;2;255;128;128:gv=38;2;255;199;153:gt=38;2;80;80;80'

  set -gx PATH ./bin $PATH
  set -gx PATH $HOME/.local/bin $PATH

  # bun
  set -gx BUN_INSTALL $HOME/.bun
  set -gx PATH $BUN_INSTALL/bin $PATH

  # git-ai
  set -gx PATH $HOME/.git-ai/bin $PATH

  # cubic
  set -gx PATH $HOME/.cubic/bin $PATH

  # opencode
  set -gx PATH $HOME/.opencode/bin $PATH

  # DALP EXA 1PASSWORD
  if test -f $HOME/.local/state/dalp/exa-mcp.fish
    source $HOME/.local/state/dalp/exa-mcp.fish
  end

  # worktrunk
  if command -q wt
    command wt config shell init fish | source
  end

  # abbreviations (expand inline, real commands in history)
  abbr -a ls eza
  abbr -a ll 'eza -l --git --icons'
  abbr -a la 'eza -la --git --icons'
  abbr -a lt 'eza --tree --level=2 --icons'

  abbr -a vim nvim
  abbr -a cat 'bat -p'
  abbr -a lg lazygit

  abbr -a co 'claude --dangerously-skip-permissions --channels plugin:telegram@claude-plugins-official'
  abbr -a claude 'claude --dangerously-skip-permissions'
  abbr -a c 'claude --dangerously-skip-permissions'
  abbr -a x codex

  # cmux
  if set -q CMUX_WORKSPACE_ID
    abbr -a cs 'cmux send'
    abbr -a csp 'cmux new-split'
    abbr -a cw 'cmux list-workspaces'
    abbr -a cp 'cmux list-panes'
    abbr -a cwn 'cmux new-workspace'
    abbr -a cid 'cmux identify'
    abbr -a ct 'cmux claude-teams --dangerously-skip-permissions'
  end

  fzf --fish | source
  zoxide init fish --cmd cd | source
end

# Added by git-ai installer on Mon Mar  9 23:11:25 CET 2026
fish_add_path -g "/Users/roderik/.git-ai/bin"

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :
