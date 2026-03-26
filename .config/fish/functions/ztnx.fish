function ztnx --description "Create worktree from Linear ticket — Codex (zellij)"
    set -l ticket $argv[1]
    if test -z "$ticket"
        echo "Usage: ztnx <ticket-id>  (e.g. ztnx PRD-6385)"
        return 1
    end

    test -n "$ZELLIJ"; or begin
        echo "Error: not in a zellij session — run zj first"
        return 1
    end

    set ticket (string upper $ticket)

    set -l json (linear issue view $ticket --json 2>&1)
    or begin
        echo "Error: could not fetch Linear issue $ticket"
        return 1
    end

    set -l title (echo $json | python3 -c "import sys,json; print(json.load(sys.stdin)['title'])" 2>/dev/null)
    set -l branch (echo $json | python3 -c "import sys,json; print(json.load(sys.stdin)['branchName'])" 2>/dev/null)

    if test -z "$title" -o -z "$branch"
        echo "Error: could not parse title/branchName from Linear issue $ticket"
        return 1
    end

    echo "Ticket:  $ticket — $title"
    echo "Branch:  $branch"

    set -l repo_root (__wt_repo_root)
    or return
    test -z "$repo_root"; and return

    cd $repo_root; and git fetch origin main; and wt switch --create --base origin/main $branch
    or return 1

    set -l worktree_path (pwd)

    __zt_zellij_setup --name "$ticket: $title" --cli "codex --full-auto"

    echo ""
    echo "$ticket checked out to: $worktree_path"

    # Send /execute command to Codex in the main pane
    # After __zt_zellij_setup, focus is on main pane where Codex is running
    sleep 3
    zellij action write-chars "/execute $ticket"
    zellij action write 10
end
