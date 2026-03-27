function wtn --description "Open a worktree — auto-detects branch, Linear ticket, or GitHub PR"
    argparse 'x' -- $argv 2>/dev/null
    set -l input $argv[1]

    set -l repo_root (__wt_repo_root)
    or return
    test -z "$repo_root"; and return

    # ── Parse input format ───────────────────────────────────────────────
    set -l mode ""
    set -l ref ""

    if test -z "$input"
        # No arg → fzf PR picker
        set mode pr
        set ref (__wtn_pick_pr $repo_root)
        test -z "$ref"; and return
    else if string match -qr '^https://github\.com/.+/pull/(\d+)' -- "$input"
        # GitHub PR URL
        set mode pr
        set ref (string match -r '/pull/(\d+)' -- "$input")[2]
    else if string match -qr '^#?(\d+)$' -- "$input"
        # PR number (123 or #123)
        set mode pr
        set ref (string match -r '\d+' -- "$input")
    else if string match -qr '^https://linear\.app/.+/issue/([A-Za-z]+-\d+)' -- "$input"
        # Linear URL
        set mode linear
        set ref (string upper (string match -r '/issue/([A-Za-z]+-\d+)' -- "$input")[2])
    else if string match -qr '^[A-Za-z]+-\d+$' -- "$input"
        # Linear ticket (PRD-123)
        set mode linear
        set ref (string upper $input)
    else
        # Bare branch name
        set mode branch
        set ref $input
    end

    # ── Dispatch ─────────────────────────────────────────────────────────
    switch $mode
        case branch
            __wtn_branch $repo_root $ref
        case linear
            __wtn_linear $repo_root $ref
        case pr
            __wtn_pr $repo_root $ref
    end
end

# ── PR picker (fzf) ─────────────────────────────────────────────────────
function __wtn_pick_pr
    set -l repo_root $argv[1]
    cd $repo_root; and gh pr list --state open --limit 50 \
        --json number,title,author,headRefName \
        --template '{{range .}}#{{.number}}\t{{.title}} ({{.author.login}}) [{{.headRefName}}]{{"\n"}}{{end}}' | \
        fzf --height=40% --reverse --header "Select PR" | awk -F'\t' '{print $1}' | tr -d '#'
end

# ── Branch path ──────────────────────────────────────────────────────────
function __wtn_branch
    set -l repo_root $argv[1]
    set -l branch $argv[2]
    set -l original_dir (pwd)

    cd $repo_root; and git fetch origin main; and wt switch --create --base origin/main $branch
    or begin; cd $original_dir; return 1; end

    set -l worktree_path (pwd)
    cd $original_dir

    set -l flags --name "$branch" --dir "$worktree_path"
    set -q _flag_x; and set -a flags -x

    __wt_tab_setup $flags
    echo "Worktree created: $worktree_path"
end

# ── Linear path ──────────────────────────────────────────────────────────
function __wtn_linear
    set -l repo_root $argv[1]
    set -l ticket $argv[2]

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

# ── PR path ──────────────────────────────────────────────────────────────
function __wtn_pr
    set -l repo_root $argv[1]
    set -l pr $argv[2]

    set -l pr_title (cd $repo_root; and gh pr view $pr --json title --jq .title 2>/dev/null)

    set -l original_dir (pwd)

    cd $repo_root; and git fetch origin main; and wt switch "pr:$pr"
    or begin; cd $original_dir; return 1; end

    zic 2>/dev/null

    set -l worktree_path (pwd)
    cd $original_dir

    set -l flags --name "PR #$pr: $pr_title" --dir "$worktree_path" --prompt "/shepherd"
    set -q _flag_x; and set -a flags -x

    __wt_tab_setup $flags
    echo "PR #$pr checked out to: $worktree_path"
end
