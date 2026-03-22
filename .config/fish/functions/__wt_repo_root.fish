function __wt_repo_root
  set -l root (git worktree list --porcelain 2>/dev/null | head -1 | sed 's/^worktree //')
  if test -n "$root"
    echo $root
    return 0
  end

  set root (for d in ~/Development/*/
    test -d "$d/.git"; and echo (string trim --right --chars=/ $d)
  end | sort | fzf --height=40% --reverse --header "Select repo" --with-nth=-1 --delimiter=/)

  if test -n "$root"
    echo $root
    return 0
  end
  return 1
end
