function otn --description "Open an opensessions worktree — auto-detects branch, Linear ticket, GitHub PR, or existing"
    argparse 'x' -- $argv 2>/dev/null
    set -l input $argv[1]
    set -l codex_flag
    set -q _flag_x; and set codex_flag -x

    set -l repo_root (__ot_repo_root)
    or return
    test -z "$repo_root"; and return

    # ── Parse input format ───────────────────────────────────────────────
    set -l mode ""
    set -l ref ""

    if test -z "$input"
        set -l selection (__otn_combined_picker $repo_root)
        test -z "$selection"; and return

        set -l kind (echo $selection | cut -f1)
        set ref (echo $selection | cut -f2)
        switch $kind
            case worktree
                __otn_existing $repo_root $ref $codex_flag
                return $status
            case pr
                set mode pr
        end
    else if string match -qr '^https://github\.com/.+/pull/(\d+)' -- "$input"
        set mode pr
        set ref (string match -r '/pull/(\d+)' -- "$input")[2]
    else if string match -qr '^#?(\d+)$' -- "$input"
        set mode pr
        set ref (string match -r '\d+' -- "$input")
    else if string match -qr '^https://linear\.app/.+/issue/([A-Za-z]+-\d+)' -- "$input"
        set mode linear
        set ref (string upper (string match -r '/issue/([A-Za-z]+-\d+)' -- "$input")[2])
    else if string match -qr '^[A-Za-z]+-\d+$' -- "$input"
        set mode linear
        set ref (string upper $input)
    else
        set mode branch
        set ref $input
    end

    # ── Dispatch ─────────────────────────────────────────────────────────
    switch $mode
        case branch
            __otn_branch $repo_root $ref $codex_flag
        case linear
            __otn_linear $repo_root $ref $codex_flag
        case pr
            __otn_pr $repo_root $ref $codex_flag
    end
end

# ── Combined picker: existing worktrees + open PRs ───────────────────────
function __otn_combined_picker
    set -l repo_root $argv[1]

    set -l entries
    for line in (git -C $repo_root worktree list | tail -n +2)
        set -l wt_path (echo $line | awk '{print $1}')
        set -l wt_branch (echo $line | awk '{print $3}' | tr -d '[]')
        set -a entries "worktree\t$wt_path\t📂 $wt_branch  ($wt_path)"
    end

    for line in (cd $repo_root; and gh pr list --state open --limit 30 \
        --json number,title,author \
        --template '{{range .}}{{.number}}\t{{.title}} ({{.author.login}}){{"\n"}}{{end}}' 2>/dev/null)
        set -l pr_num (echo $line | cut -f1)
        set -l pr_desc (echo $line | cut -f2)
        set -a entries "pr\t$pr_num\t🔀 #$pr_num  $pr_desc"
    end

    if test -z "$entries"
        echo "No worktrees or open PRs found"
        return 1
    end

    set -l selected (printf '%s\n' $entries | \
        fzf --height=40% --reverse --header "opensessions: Worktrees & PRs" \
            --delimiter='\t' --with-nth=3 | \
        cut -f1,2)
    echo $selected
end

# ── Open existing worktree ───────────────────────────────────────────────
function __otn_existing
    set -l repo_root $argv[1]
    set -l target $argv[2]
    set -l codex_flag $argv[3]

    set -l branch_name (git -C $target branch --show-current 2>/dev/null)

    set -l flags --name "os: $branch_name" --dir "$target"
    test -n "$codex_flag"; and set -a flags $codex_flag

    __wt_tab_setup $flags
end

# ── Create branch worktree ───────────────────────────────────────────────
function __otn_branch
    set -l repo_root $argv[1]
    set -l branch $argv[2]
    set -l codex_flag $argv[3]
    set -l original_dir (pwd)

    cd $repo_root; and git fetch origin main; and wt switch --create --base origin/main $branch
    or begin; cd $original_dir; return 1; end

    set -l worktree_path (pwd)
    cd $original_dir

    set -l flags --name "os: $branch" --dir "$worktree_path"
    test -n "$codex_flag"; and set -a flags $codex_flag

    __wt_tab_setup $flags
    echo "Worktree created: $worktree_path"
end

# ── Linear ticket worktree ───────────────────────────────────────────────
function __otn_linear
    set -l repo_root $argv[1]
    set -l ticket $argv[2]
    set -l codex_flag $argv[3]

    set -l json (linear issue view $ticket --json 2>&1)
    or begin
        echo "Error: could not fetch Linear issue $ticket"
        return 1
    end

    set -l title (echo $json | jq -r '.title' 2>/dev/null)
    set -l branch (echo $json | jq -r '.branchName' 2>/dev/null)

    if test -z "$title" -o "$title" = null -o -z "$branch" -o "$branch" = null
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

    set -l flags --name "os: $ticket: $title" --dir "$worktree_path" --prompt "/execute $ticket"
    test -n "$codex_flag"; and set -a flags $codex_flag

    __wt_tab_setup $flags
    echo "$ticket checked out to: $worktree_path"
end

# ── PR worktree ──────────────────────────────────────────────────────────
function __otn_pr
    set -l repo_root $argv[1]
    set -l pr $argv[2]
    set -l codex_flag $argv[3]

    set -l pr_title (cd $repo_root; and gh pr view $pr --json title --jq .title 2>/dev/null)

    set -l original_dir (pwd)

    cd $repo_root; and git fetch origin main; and wt switch "pr:$pr"
    or begin; cd $original_dir; return 1; end

    set -l worktree_path (pwd)
    cd $original_dir

    set -l flags --name "os: PR #$pr: $pr_title" --dir "$worktree_path" --prompt "/shepherd"
    test -n "$codex_flag"; and set -a flags $codex_flag

    __wt_tab_setup $flags
    echo "PR #$pr checked out to: $worktree_path"
end
