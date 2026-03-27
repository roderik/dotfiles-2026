function wto --description "Launch Claude Code orchestrator in the main DALP repo"
    # Find main repo across platforms
    set -l main_repo
    for dir in ~/Development/dalp ~/dev/dalp
        if test -d "$dir/.git"
            set main_repo $dir
            break
        end
    end

    if test -z "$main_repo"
        echo "Error: DALP repo not found in ~/Development/dalp or ~/dev/dalp"
        return 1
    end

    if test -n "$ZELLIJ"
        zellij action rename-tab "Orchestrator" 2>/dev/null
    end

    cd $main_repo
    echo "Orchestrator tab ready at $main_repo"
end
