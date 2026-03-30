function zjr --description "Start or attach to a zellij session on a remote host"
    set -l host $FLOCK_REMOTE_HOST
    if test -n "$argv[1]"
        set host $argv[1]
    end

    if test -z "$host"
        echo "Error: no remote host specified and \$FLOCK_REMOTE_HOST is not set" >&2
        return 1
    end

    ssh -t $host "zellij attach --create"
end
