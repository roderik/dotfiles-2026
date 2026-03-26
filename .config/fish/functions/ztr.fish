function ztr --description "Remove current worktree and return to main (zellij)"
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

    # Close the zellij tab if inside a session
    if test -n "$ZELLIJ"
        echo "Closing zellij tab"
        zellij action close-tab 2>/dev/null
    end
end
