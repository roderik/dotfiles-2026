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

    cd $target
    and __zt_zellij_setup --name (git branch --show-current 2>/dev/null)
end
