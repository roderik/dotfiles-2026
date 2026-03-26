function wtnx --description "Create worktree from Linear ticket (Codex)"
  set -l ticket $argv[1]
  if test -z "$ticket"
    echo "Usage: wtnx <ticket-id>  (e.g. wtnx PRD-6385)"
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

  # Get the worktree path
  set -l worktree_path (pwd)

  # Set cmux workspace title and layout — launch Codex instead of Claude
  __wt_cmux_rename "$ticket: $title"
  __wt_cmux_setup --cli "codex --full-auto"

  echo ""
  echo "$ticket checked out to: $worktree_path"

  # Send /execute command to Codex running in the main pane
  set -l ws_id
  if test -n "$CMUX_WORKSPACE_ID"
    set ws_id "$CMUX_WORKSPACE_ID"
  else
    set ws_id (cmux identify --json 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin)['caller']['workspace_ref'])" 2>/dev/null)
  end
  if test -n "$ws_id"
    set -l main_pane (cmux list-panes --workspace "$ws_id" 2>/dev/null | grep -oE 'pane:[0-9]+' | head -1)
    set -l main_surface (cmux list-pane-surfaces --workspace "$ws_id" --pane "$main_pane" 2>/dev/null | grep -oE 'surface:[0-9]+' | head -1)
    if test -n "$main_surface"
      sleep 3
      cmux send --workspace "$ws_id" --surface "$main_surface" "/execute $ticket\n" 2>/dev/null
    end
  end
end
