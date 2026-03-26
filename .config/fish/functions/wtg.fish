function wtg --description "Pick a PR and check it out as a worktree"
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

  # Fetch PR title for cmux workspace
  set -l pr_title (cd $repo_root; and gh pr view $pr --json title --jq .title 2>/dev/null)

  cd $repo_root; and git fetch origin main; and wt switch "pr:$pr"; and zic
  and __wt_cmux_rename "PR #$pr: $pr_title"
  and __wt_cmux_setup

  echo ""
  echo "PR #$pr checked out to: "(pwd)
end
