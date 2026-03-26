function zto --description "Launch Claude Code orchestrator in the main DALP repo (zellij)"
    test -n "$ZELLIJ"; or begin
        echo "Error: not in a zellij session — run zj first"
        return 1
    end

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

    zellij action rename-tab "Orchestrator" 2>/dev/null
    cd $main_repo
    echo "Orchestrator tab ready at $main_repo"
end
