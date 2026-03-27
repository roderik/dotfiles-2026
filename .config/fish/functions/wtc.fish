function wtc --description "Create a new worktree and open a workspace tab"
    argparse 'x' -- $argv 2>/dev/null
    set -l branch $argv[1]

    if test -z "$branch"
        echo "Usage: wtc [-x] <branch-name>"
        return 1
    end

    set -l repo_root (__wt_repo_root)
    or return
    test -z "$repo_root"; and return

    set -l original_dir (pwd)

    cd $repo_root; and git fetch origin main; and wt switch --create --base origin/main $branch
    or begin; cd $original_dir; return 1; end

    set -l worktree_path (pwd)
    cd $original_dir

    set -l flags --name "$branch" --dir "$worktree_path"
    set -q _flag_x; and set -a flags -x

    __wt_tab_setup $flags

    echo "Worktree created: $worktree_path"
end
