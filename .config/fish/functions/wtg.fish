# Switch to a PR worktree: wtg 123 or wtg #123
function wtg
    set -l pr (string replace '#' '' -- $argv[1])
    if test -z "$pr"
        echo "Usage: wtg <number>"
        return 1
    end
    git fetch origin main && wt switch "pr:$pr"
end
