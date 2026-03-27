function wtl --description "List worktrees and open selection in a workspace tab"
    argparse 'x' -- $argv 2>/dev/null

    set -l repo_root (__wt_repo_root)
    or return
    test -z "$repo_root"; and return

    set -l target (git -C $repo_root worktree list | \
        fzf --height=40% --reverse --header "Select worktree" | awk '{print $1}')
    test -z "$target"; and return

    set -l branch_name (git -C $target branch --show-current 2>/dev/null)

    set -l flags --name "$branch_name" --dir "$target"
    set -q _flag_x; and set -a flags -x

    __wt_tab_setup $flags
end
