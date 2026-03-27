function wtr --description "Remove current worktree and close the workspace tab"
    set -l current_branch (git branch --show-current 2>/dev/null)

    if test -z "$current_branch"
        echo "Error: not in a git repository"
        return 1
    end

    set -l main_worktree (git worktree list --porcelain | head -1 | sed 's/^worktree //')

    if test "$PWD" = "$main_worktree"; or string match -q "$main_worktree/*" $PWD
        echo "Error: already in the main worktree — nothing to remove"
        return 1
    end

    echo "Removing worktree: $current_branch"
    cd $main_worktree; or return 1
    wt remove --yes --foreground --force $current_branch
    git remote prune origin 2>/dev/null
    git branch -D $current_branch 2>/dev/null
    echo "Back in main worktree: $main_worktree"

    # Close the tab/workspace
    if test -n "$ZELLIJ"
        zellij action close-tab 2>/dev/null
    else if set -q CMUX_WORKSPACE_ID
        cmux close-workspace 2>/dev/null
    end
end
