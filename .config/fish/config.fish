if status is-interactive
    touch ~/.hushlogin
    set -U fish_greeting

    # ── editors ──────────────────────────────────────────────────────────
    set -gx EDITOR nvim
    set -gx VISUAL nvim
    set -gx AI_EDITOR claude

    # ── theme ────────────────────────────────────────────────────────────
    set -gx BAT_THEME Vesper
    set -gx EZA_COLORS 'di=1;37:fi=0;37:ln=36:ex=38;2;255;199;153:sn=38;2;160;160;160:sb=38;2;160;160;160:uu=38;2;160;160;160:da=38;2;139;139;139:ga=38;2;153;255;228:gm=38;2;255;199;153:gd=38;2;255;128;128:gv=38;2;255;199;153:gt=38;2;80;80;80'

    # ── PATH (shared) ────────────────────────────────────────────────────
    set -gx BUN_INSTALL $HOME/.bun
    fish_add_path -g $BUN_INSTALL/bin
    fish_add_path -g $HOME/.local/bin
    fish_add_path -g $HOME/.cargo/bin
    fish_add_path -g $HOME/.opencode/bin
    fish_add_path -g $HOME/.git-ai/bin
    fish_add_path -g $HOME/.foundry/bin

    # ── PATH (platform-specific) ─────────────────────────────────────────
    switch (uname)
        case Darwin
            /opt/homebrew/bin/brew shellenv | source
            set -gx HOMEBREW_NO_ENV_HINTS 1
            fish_add_path -g ./bin
            fish_add_path -g $HOME/.cubic/bin
        case Linux
            fish_add_path -g /usr/local/bin
    end

    # ── DALP EXA 1PASSWORD (Mac only) ────────────────────────────────────
    if test -f $HOME/.local/state/dalp/exa-mcp.fish
        source $HOME/.local/state/dalp/exa-mcp.fish
    end

    # ── worktrunk ────────────────────────────────────────────────────────
    if command -q wt
        command wt config shell init fish | source
    end

    # ── abbreviations ────────────────────────────────────────────────────
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

    # ── cmux (only inside cmux sessions) ─────────────────────────────────
    if set -q CMUX_WORKSPACE_ID
        abbr -a cs 'cmux send'
        abbr -a csp 'cmux new-split'
        abbr -a cw 'cmux list-workspaces'
        abbr -a cp 'cmux list-panes'
        abbr -a cwn 'cmux new-workspace'
        abbr -a cid 'cmux identify'
        abbr -a ct 'cmux claude-teams --dangerously-skip-permissions'
    end

    # ── FZF ──────────────────────────────────────────────────────────────
    set -gx FZF_DEFAULT_OPTS "--height 40% --layout=reverse --border --info=inline"
    switch (uname)
        case Darwin
            fzf --fish | source
        case Linux
            if test -f /usr/share/doc/fzf/examples/key-bindings.fish
                source /usr/share/doc/fzf/examples/key-bindings.fish
            else if command -q fzf
                fzf --fish | source
            end
    end

    # ── zoxide ───────────────────────────────────────────────────────────
    zoxide init fish --cmd cd | source

    # ── prompt ──────────────────────────────────────────────────────────
    starship init fish | source

    # ── pager ────────────────────────────────────────────────────────────
    set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
    set -gx MANROFFOPT "-c"

    # ── platform extras ──────────────────────────────────────────────────
    switch (uname)
        case Darwin
            # OrbStack
            source ~/.orbstack/shell/init2.fish 2>/dev/null; or true
        case Linux
            # docker-secure aliases
            if test -f /usr/local/bin/docker-secure
                abbr -a docker-local '/usr/local/bin/docker-secure local'
                abbr -a docker-tailscale '/usr/local/bin/docker-secure tailscale'
            end
    end
end
