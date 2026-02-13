# Create a stacked worktree: wts [branch-name]
# Selects parent via fzf, creates worktree with wt, registers stack with git-town, launches claude
function wts
    set -l branch_name $argv[1]

    # Select parent branch with fzf
    set -l parent (begin
        git branch --format='%(refname:short)'
        git branch -r --format='%(refname:short)' | sed 's|^origin/||'
    end | sort -u | grep -v '^HEAD$' | \
        fzf --header "Select parent branch to stack on" \
            --preview 'git log --oneline --graph -10 {}' \
            --preview-window=right:50%)

    if test -z "$parent"
        echo "No branch selected"
        return 1
    end

    # Prompt for branch name if not provided
    if test -z "$branch_name"
        read -P "New branch name: " branch_name
        if test -z "$branch_name"
            echo "No branch name"
            return 1
        end
    end

    # Register stacked parent with git-town, then create worktree and launch Claude
    git fetch origin main
    git-town set-parent "$parent"
    wt switch --create "$branch_name" --base "$parent" --execute=claude
end
