# Zellij - attach or create session via `zj`
function zj
    if set -q ZELLIJ
        return 0
    end
    zellij attach -c $argv
end
