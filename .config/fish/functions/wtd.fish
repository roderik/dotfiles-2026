function wtd --description "Delete a worktree via fzf picker (current worktree preselected)"
    set -l repo_root (__wt_repo_root)
    or return
    test -z "$repo_root"; and return

    set -l main_worktree (git -C $repo_root worktree list --porcelain | head -1 | sed 's/^worktree //')
    set -l current_branch (git branch --show-current 2>/dev/null)

    # Build fzf list: skip main worktree, annotate current with (current)
    set -l target (git -C $repo_root worktree list | tail -n +2 | while read -l line
        set -l wt_path (echo $line | awk '{print $1}')
        set -l wt_branch (echo $line | awk '{print $3}' | tr -d '[]')
        if test "$wt_branch" = "$current_branch"
            echo "$line (current)"
        else
            echo "$line"
        end
    end | fzf --height=40% --reverse --header "Delete which worktree?" \
              --query "(current)" --select-1 | sed 's/ (current)$//' | awk '{print $1}')
    test -z "$target"; and return

    set -l branch (git -C $repo_root worktree list | grep "^$target " | awk '{print $3}' | tr -d '[]')
    set -l is_current false

    if test "$PWD" = "$target"; or string match -q "$target/*" $PWD
        set is_current true
        cd $repo_root
    end

    echo "Removing worktree: $branch ($target)"
    wt -C $repo_root remove --yes --foreground --force $branch
    git -C $repo_root remote prune origin 2>/dev/null
    git -C $repo_root branch -D $branch 2>/dev/null

    # Close the tab/workspace if we just removed the current worktree
    if test "$is_current" = true
        if test -n "$ZELLIJ"
            zellij action close-tab 2>/dev/null
        else if set -q CMUX_WORKSPACE_ID
            cmux close-workspace 2>/dev/null
        end
    end
end
