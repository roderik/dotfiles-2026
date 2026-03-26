function __zt_zellij_rename --description "Rename current zellij tab"
    set -l name $argv[1]
    test -z "$name"; and return
    test -n "$ZELLIJ"; or return
    zellij action rename-tab "$name" 2>/dev/null
end
