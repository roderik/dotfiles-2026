function zj --description "Attach to the dalp zellij session, or create it"
    if test -n "$ZELLIJ"
        echo "Already inside zellij"
        return 0
    end

    # Attach if session exists, otherwise create
    zellij attach dalp 2>/dev/null; or zellij --session dalp
end
