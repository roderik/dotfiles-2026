function __zt_zellij_setup --description "Create a new zellij tab with the wt layout (lazygit + terminal + Claude)"
    test -n "$ZELLIJ"; or begin
        echo "zellij: not in a session — run zj first"
        return 1
    end

    set -l cli "claude --dangerously-skip-permissions"
    set -l prompt ""
    set -l wt_cmd ""

    argparse 'force' 'cli=' 'prompt=' 'name=' 'wt-cmd=' -- $argv 2>/dev/null

    set -q _flag_cli; and set cli $_flag_cli
    set -q _flag_prompt; and set prompt $_flag_prompt
    set -q _flag_wt_cmd; and set wt_cmd $_flag_wt_cmd

    set -l workdir (pwd)

    # Create new tab with the wt layout (lazygit starts automatically via layout command)
    zellij action new-tab --layout wt --cwd "$workdir" 2>/dev/null

    # Wait for panes to initialize
    sleep 0.5

    # Rename the NEW tab (must happen after new-tab switches focus to it)
    if set -q _flag_name; and test -n "$_flag_name"
        zellij action rename-tab "$_flag_name" 2>/dev/null
    end

    # If a worktree command was provided, run it first in the main pane, then launch CLI
    if test -n "$wt_cmd"
        # Run the wt switch command, then launch CLI on success
        if test -n "$prompt"
            zellij action write-chars "$wt_cmd && $cli '$prompt'"
        else
            zellij action write-chars "$wt_cmd && $cli"
        end
    else
        # No worktree command — just launch CLI directly
        if test -n "$prompt"
            zellij action write-chars "$cli '$prompt'"
        else
            zellij action write-chars "$cli"
        end
    end
    zellij action write 10
end
