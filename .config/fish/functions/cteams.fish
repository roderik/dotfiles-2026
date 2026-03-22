function cteams --description 'Launch Claude Code agent teams in cmux with a workpad viewer'
    if not command -q cmux
        echo "cmux not found" >&2
        return 1
    end

    if not set -q CMUX_WORKSPACE_ID
        echo "Not running inside cmux" >&2
        return 1
    end

    # Open a right split with a markdown workpad viewer
    set -l workpad_dir .agents
    set -l workpad_file $workpad_dir/workpad.md

    # Create the workpad file if it doesn't exist
    if not test -f $workpad_file
        mkdir -p $workpad_dir
        echo "# Workpad" > $workpad_file
        echo "" >> $workpad_file
        echo "_Waiting for agent activity..._" >> $workpad_file
    end

    # Open markdown viewer in a right split (live-reloads on file change)
    cmux new-split right
    cmux markdown open (realpath $workpad_file) 2>/dev/null &

    # Focus back to the main pane and launch claude-teams
    cmux focus-pane --pane pane:1 2>/dev/null
    cmux claude-teams --dangerously-skip-permissions $argv
end
