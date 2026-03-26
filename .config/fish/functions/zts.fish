function zts --description "Set up or repair zellij tab layout (lazygit + terminal pane)"
    test -n "$ZELLIJ"; or begin
        echo "Error: not in a zellij session — run zj first"
        return 1
    end

    if contains -- --force $argv
        __zt_zellij_setup --force
    else
        __zt_zellij_setup
    end
end
