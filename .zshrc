export PATH="$HOME/.local/bin:$PATH"

ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim

# Install missing modules and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
  source /opt/homebrew/opt/zimfw/share/zimfw.zsh init
fi

# Initialize modules.
source ${ZIM_HOME}/init.zsh

# bun completions
[ -s "/Users/roderik/.bun/_bun" ] && source "/Users/roderik/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

source <(fnm env --shell zsh --use-on-cd)

export HOMEBREW_NO_ENV_HINTS=1