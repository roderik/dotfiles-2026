function __wt_repo_root
    set -l root (git worktree list --porcelain 2>/dev/null | head -1 | sed 's/^worktree //')
    if test -n "$root"
        echo $root
        return 0
    end

    # Scan known dev directories for git repos
    set -l candidates
    for dir in ~/Development ~/dev
        test -d "$dir"; or continue
        for d in $dir/*/
            test -d "$d/.git"; and set -a candidates (string trim --right --chars=/ $d)
        end
    end

    if test (count $candidates) -eq 0
        echo "Error: no git repos found in ~/Development or ~/dev" >&2
        return 1
    end

    set root (printf '%s\n' $candidates | sort | fzf --height=40% --reverse --header "Select repo" --with-nth=-1 --delimiter=/)

    if test -n "$root"
        echo $root
        return 0
    end
    return 1
end
