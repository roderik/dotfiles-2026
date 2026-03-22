function find --wraps fd --description "Use fd, fallback to find for find-style args"
    # Detect find-style arguments
    for arg in $argv
        switch $arg
            case '-name' '-iname' '-type' '-exec' '-print' '-delete' '-maxdepth' '-mindepth' '-mtime' '-atime' '-ctime' '-perm' '-user' '-group' '-size' '-newer' '-empty' '-prune' '-ok' '-print0' '-regex' '-path' '-not' '-and' '-or' '-xdev' '-mount' '-ls' '-fls' '-fprintf' '-wholename' '-samefile' '-inum' '-links' '-readable' '-writable' '-executable'
                echo "find-style args detected, using real find" >&2
                command find $argv
                return
            end
    end
    fd $argv
end
