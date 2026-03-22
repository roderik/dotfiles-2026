function wtl --description "List worktrees and cd to selection"
  set -l repo_root (__wt_repo_root)
  or return
  test -z "$repo_root"; and return

  set -l target (git -C $repo_root worktree list | \
    fzf --height=40% --reverse --header "Select worktree" | awk '{print $1}')
  test -z "$target"; and return

  cd $target
  and __wt_cmux_rename (git branch --show-current 2>/dev/null)
  and __wt_cmux_setup
end
