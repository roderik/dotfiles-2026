function ztc --description "Create a new worktree (zellij)"
    test -n "$ZELLIJ"; or begin
        echo "Error: not in a zellij session — run zj first"
        return 1
    end

    set -l repo_root (__wt_repo_root)
    or return
    test -z "$repo_root"; and return

    cd $repo_root; and git fetch origin main
    or return 1

    # Open tab at repo root, create worktree inside the new tab
    __zt_zellij_setup --name $argv[1] --wt-cmd "wt switch --create --base origin/main $argv[1]"

    echo ""
    echo "Worktree tab opened for: $argv[1]"
end
