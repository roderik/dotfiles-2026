function __ot_repo_root
    # If already in an opensessions worktree, resolve root
    set -l root (git worktree list --porcelain 2>/dev/null | head -1 | sed 's/^worktree //')
    if test -n "$root"
        set -l remote (git -C $root remote get-url origin 2>/dev/null)
        if string match -q '*opensessions*' -- "$remote"
            echo $root
            return 0
        end
    end

    # Scan known dev directories for opensessions
    for dir in ~/Development/opensessions ~/dev/opensessions
        if test -d "$dir/.git"
            echo $dir
            return 0
        end
    end

    echo "Error: opensessions repo not found in ~/Development or ~/dev" >&2
    return 1
end
