function ztc --description "Create a new worktree (zellij)"
    test -n "$ZELLIJ"; or begin
        echo "Error: not in a zellij session — run zj first"
        return 1
    end

    set -l repo_root (__wt_repo_root)
    or return
    test -z "$repo_root"; and return

    cd $repo_root; and git fetch origin main; and wt switch --create --base origin/main $argv
    and __zt_zellij_rename $argv[1]
    and __zt_zellij_setup

    echo ""
    echo "Worktree created: "(pwd)
end
