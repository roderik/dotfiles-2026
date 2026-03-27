function oto --description "Launch Claude Code orchestrator in the opensessions repo"
    set -l main_repo
    for dir in ~/Development/opensessions ~/dev/opensessions
        if test -d "$dir/.git"
            set main_repo $dir
            break
        end
    end

    if test -z "$main_repo"
        echo "Error: opensessions repo not found in ~/Development or ~/dev"
        return 1
    end

    if test -n "$ZELLIJ"
        zellij action rename-tab "os: Orchestrator" 2>/dev/null
    end

    cd $main_repo
    echo "opensessions orchestrator ready at $main_repo"
end
