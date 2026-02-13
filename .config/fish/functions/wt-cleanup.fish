# Worktrunk - worktree cleanup helper
function wt-cleanup
    set -l to_remove

    echo "Scanning worktrees for merged/closed PRs..."
    echo

    for line in (wt list --format=json | jq -r '.[] | del(.statusline, .symbols) | [.branch // "", (.is_main | tostring), (.is_current | tostring), (.worktree.detached | tostring)] | @tsv')
        set -l parts (string split \t -- $line)
        set -l branch $parts[1]
        set -l is_main $parts[2]
        set -l is_current $parts[3]
        set -l detached $parts[4]

        test "$is_main" = true; and continue
        test "$is_current" = true; and continue
        test "$detached" = true; and continue
        test -z "$branch" -o "$branch" = null; and continue
        string match -rq '^[a-zA-Z0-9]' -- $branch; or continue

        set -l pr_state (gh pr view "$branch" --json state 2>/dev/null | jq -r '.state // empty')

        switch "$pr_state"
            case MERGED
                echo "  ✓ $branch (merged) — will remove"
                set -a to_remove $branch
            case CLOSED
                echo "  ✓ $branch (closed) — will remove"
                set -a to_remove $branch
            case OPEN
                echo "  → $branch (open) — skipping"
            case '*'
                echo "  ? $branch (no PR) — skipping"
        end
    end

    echo

    if test (count $to_remove) -eq 0
        echo "Nothing to clean up."
        return 0
    end

    echo "Removing "(count $to_remove)" worktree(s)..."
    wt remove --yes --foreground $to_remove
    echo "Done."
end
