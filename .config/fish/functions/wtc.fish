function wtc --description "Create a new worktree, optionally launch agent via ACP"
  set -l repo_root (__wt_repo_root)
  or return
  test -z "$repo_root"; and return

  cd $repo_root; and git fetch origin main; and wt switch --create --base origin/main $argv
  and __wt_cmux_rename $argv[1]
  and __wt_cmux_setup

  # Get the worktree path
  set -l worktree_path (pwd)

  echo ""
  echo "Worktree created: $worktree_path"
  echo ""
  echo "To spawn an ACP agent for this worktree, run one of:"
  echo "  acpx claude --cwd '$worktree_path' --label '$argv[1]' 'start working'"
  echo "  acpx codex --cwd '$worktree_path' --label '$argv[1]' '\$start working'"
  echo ""
  echo "Then control from Telegram with /acp commands"
end
