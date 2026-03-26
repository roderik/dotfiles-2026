function __zt_zellij_setup --description "Create a new zellij tab with the wt layout (lazygit + terminal + Claude)"
    test -n "$ZELLIJ"; or begin
        echo "zellij: not in a session — run zj first"
        return 1
    end

    set -l cli "claude --dangerously-skip-permissions"
    set -l prompt ""

    argparse 'force' 'cli=' 'prompt=' -- $argv 2>/dev/null

    set -q _flag_cli; and set cli $_flag_cli
    set -q _flag_prompt; and set prompt $_flag_prompt

    set -l workdir (pwd)

    # Create new tab with the wt layout (lazygit starts automatically via layout command)
    zellij action new-tab --layout wt --cwd "$workdir" 2>/dev/null

    # Wait for panes to initialize
    sleep 0.5

    # Main pane is focused (layout: focus=true). Type the CLI command.
    if test -n "$prompt"
        zellij action write-chars "$cli '$prompt'"
    else
        zellij action write-chars "$cli"
    end
    zellij action write 10
end
