function zto --description "Launch Claude Code orchestrator in the main DALP repo (zellij)"
    set -l main_repo ~/Development/dalp
    if not test -d "$main_repo/.git"
        echo "Error: main DALP repo not found at $main_repo"
        return 1
    end

    test -n "$ZELLIJ"; or begin
        echo "Error: not in a zellij session — run zj first"
        return 1
    end

    zellij action rename-tab "Orchestrator" 2>/dev/null

    cd $main_repo
    echo "Orchestrator tab ready at $main_repo"
end
