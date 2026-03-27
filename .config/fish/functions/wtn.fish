function wtn --description "Create worktree from Linear ticket and open a workspace tab"
    argparse 'x' -- $argv 2>/dev/null
    set -l ticket $argv[1]

    if test -z "$ticket"
        echo "Usage: wtn [-x] <ticket-id>  (e.g. wtn PRD-6385)"
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

    set -l original_dir (pwd)

    cd $repo_root; and git fetch origin main; and wt switch --create --base origin/main $branch
    or begin; cd $original_dir; return 1; end

    set -l worktree_path (pwd)
    cd $original_dir

    set -l flags --name "$ticket: $title" --dir "$worktree_path" --prompt "/execute $ticket"
    set -q _flag_x; and set -a flags -x

    __wt_tab_setup $flags

    echo "$ticket checked out to: $worktree_path"
end
