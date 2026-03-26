function zjr --description "Connect to daystrom and attach/create zellij session"
    if test -n "$ZELLIJ"
        echo "Already inside zellij"
        return 0
    end

    ssh -t roderik@daystrom.bigeye-carat.ts.net "zellij attach --create dalp"
end
