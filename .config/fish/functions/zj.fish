function zj --description "Start or attach to a zellij session"
    if test -n "$ZELLIJ"
        echo "Already inside a zellij session"
        return 0
    end

    if test -n "$argv[1]"
        zellij attach --create $argv[1]
    else
        zellij attach --create
    end
end
