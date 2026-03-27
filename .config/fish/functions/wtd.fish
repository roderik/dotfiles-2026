function wtd --description "Delete a worktree via fzf picker"
    set -l repo_root (__wt_repo_root)
    or return
    test -z "$repo_root"; and return

    set -l target (git -C $repo_root worktree list | tail -n +2 | \
        fzf --height=40% --reverse --header "Delete which worktree?" | awk '{print $1}')
    test -z "$target"; and return

    set -l branch (git -C $repo_root worktree list | grep "^$target " | awk '{print $3}' | tr -d '[]')

    if test "$PWD" = "$target"; or string match -q "$target/*" $PWD
        cd $repo_root
    end

    echo "Removing worktree: $branch ($target)"
    wt -C $repo_root remove --yes --foreground --force $branch
    git -C $repo_root remote prune origin 2>/dev/null
    git -C $repo_root branch -D $branch 2>/dev/null
end
