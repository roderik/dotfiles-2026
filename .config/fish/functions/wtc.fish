function wtc --description "Create a new worktree"
  set -l repo_root (__wt_repo_root)
  or return
  test -z "$repo_root"; and return

  cd $repo_root; and git fetch origin main; and wt switch --create --base origin/main $argv
  and __wt_cmux_rename $argv[1]
  and __wt_cmux_setup

  echo ""
  echo "Worktree created: "(pwd)
end
