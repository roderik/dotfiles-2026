function ztl --description "List worktrees and cd to selection (zellij)"
    test -n "$ZELLIJ"; or begin
        echo "Error: not in a zellij session — run zj first"
        return 1
    end

    set -l repo_root (__wt_repo_root)
    or return
    test -z "$repo_root"; and return

    set -l target (git -C $repo_root worktree list | \
        fzf --height=40% --reverse --header "Select worktree" | awk '{print $1}')
    test -z "$target"; and return

    set -l branch_name (git -C $target branch --show-current 2>/dev/null)

    # Open tab at repo root, cd to the worktree inside the new tab
    cd $repo_root
    __zt_zellij_setup --name "$branch_name" --wt-cmd "cd $target"
end
