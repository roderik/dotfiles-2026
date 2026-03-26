function wtn --description "Create worktree from Linear ticket"
  set -l ticket $argv[1]
  if test -z "$ticket"
    echo "Usage: wtn <ticket-id>  (e.g. wtn PRD-6385)"
    return 1
  end

  # Uppercase the ticket ID for Linear CLI
  set ticket (string upper $ticket)

  # Fetch ticket from Linear
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

  # Find repo root and create worktree
  set -l repo_root (__wt_repo_root)
  or return
  test -z "$repo_root"; and return

  cd $repo_root; and git fetch origin main; and wt switch --create --base origin/main $branch
  or return 1

  # Get the worktree path (wt switch should have put us there)
  set -l worktree_path (pwd)

  # Set cmux workspace title and layout, start Claude, then send /execute
  __wt_cmux_rename "$ticket: $title"
  __wt_cmux_setup --prompt "/execute $ticket"

  echo ""
  echo "$ticket checked out to: $worktree_path"
end
