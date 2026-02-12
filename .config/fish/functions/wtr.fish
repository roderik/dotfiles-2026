# Remove current worktree and return to main
function wtr
    set -l current_branch (git branch --show-current 2>/dev/null)

    if test -z "$current_branch"
        echo "Error: not in a git repository"
        return 1
    end

    set -l main_worktree (git worktree list --porcelain | head -1 | sed 's/^worktree //')

    if string match -q "$main_worktree*" "$PWD"
        echo "Error: already in the main worktree — nothing to remove"
        return 1
    end

    echo "Removing worktree: $current_branch"
    cd "$main_worktree"; or return 1
    wt remove --yes --foreground "$current_branch"
    echo "Back in main worktree: $main_worktree"
end
