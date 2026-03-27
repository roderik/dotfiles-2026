function wtg --description "Pick a PR and check it out as a workspace tab"
    argparse 'x' -- $argv 2>/dev/null

    set -l repo_root (__wt_repo_root)
    or return
    test -z "$repo_root"; and return

    set -l pr
    if test -n "$argv[1]"
        set pr $argv[1]
    else
        set pr (cd $repo_root; and gh pr list --state open --limit 50 \
            --json number,title,author,headRefName \
            --template '{{range .}}#{{.number}}\t{{.title}} ({{.author.login}}) [{{.headRefName}}]{{"\n"}}{{end}}' | \
            fzf --height=40% --reverse --header "Select PR" | awk -F'\t' '{print $1}' | tr -d '#')
    end
    test -z "$pr"; and return

    set -l pr_title (cd $repo_root; and gh pr view $pr --json title --jq .title 2>/dev/null)

    set -l original_dir (pwd)

    cd $repo_root; and git fetch origin main; and wt switch "pr:$pr"
    or begin; cd $original_dir; return 1; end

    # Install deps in the PR worktree
    zic 2>/dev/null

    set -l worktree_path (pwd)
    cd $original_dir

    set -l flags --name "PR #$pr: $pr_title" --dir "$worktree_path"
    set -q _flag_x; and set -a flags -x

    __wt_tab_setup $flags

    echo "PR #$pr checked out to: $worktree_path"
end
