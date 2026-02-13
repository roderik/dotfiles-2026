# Terminal Title (git root or current directory)
function fish_title
    set -l git_root (git rev-parse --show-toplevel 2>/dev/null)
    if test -n "$git_root"
        basename $git_root
    else
        basename $PWD
    end
end
