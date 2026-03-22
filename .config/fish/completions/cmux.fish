# Fish completions for cmux
set -l cmux_commands \
    bind-key break-pane browser capabilities capture-pane claude-hook \
    clear-history clear-log clear-notifications clear-progress clear-status \
    close-surface close-window close-workspace current-window current-workspace \
    display-message drag-surface-to-split find-window focus-pane focus-panel \
    focus-window help identify join-pane last-pane \
    list-buffers list-log list-notifications list-pane-surfaces list-panels \
    list-panes list-status list-windows list-workspaces log \
    move-surface move-workspace-to-window new-pane new-split new-surface \
    new-window new-workspace next-window notify paste-buffer ping pipe-pane \
    popup read-screen refresh-surfaces rename-tab rename-window rename-workspace \
    reorder-surface reorder-workspace resize-pane respawn-pane select-workspace \
    send send-key send-key-panel send-panel set-app-focus set-buffer set-hook \
    set-progress set-status sidebar-state simulate-app-active surface-health \
    swap-pane tab-action trigger-flash version wait-for workspace-action

complete -c cmux -f

# Global options
complete -c cmux -l socket -d 'Socket path' -r
complete -c cmux -l window -d 'Window ID' -r
complete -c cmux -l password -d 'Socket password' -r
complete -c cmux -l json -d 'Output as JSON'
complete -c cmux -l id-format -d 'ID format' -r -a 'refs uuids both'
complete -c cmux -l version -d 'Show version'

# Subcommands (only when no subcommand given yet)
for cmd in $cmux_commands
    complete -c cmux -n "not __fish_seen_subcommand_from $cmux_commands" -a $cmd
end

# new-split directions
complete -c cmux -n "__fish_seen_subcommand_from new-split" -a "left right up down"

# Common flags for workspace-scoped commands
for cmd in list-panes list-panels new-split send
    complete -c cmux -n "__fish_seen_subcommand_from $cmd" -l workspace -d 'Workspace ID' -r
end

# Common flags for surface-scoped commands
for cmd in new-split close-surface move-surface reorder-surface
    complete -c cmux -n "__fish_seen_subcommand_from $cmd" -l surface -d 'Surface ID' -r
end

# browser subcommands
set -l browser_commands \
    open navigate back forward reload snapshot click fill press keydown keyup \
    select scroll get is find frame dialog download cookies storage tab console \
    errors highlight state addinitscript addscript addstyle viewport \
    geolocation geo offline trace network screencast input identify

complete -c cmux -n "__fish_seen_subcommand_from browser; and not __fish_seen_subcommand_from $browser_commands" -a "$browser_commands"

# workspace-action
complete -c cmux -n "__fish_seen_subcommand_from workspace-action" -l action -d 'Action name' -r
complete -c cmux -n "__fish_seen_subcommand_from workspace-action" -l title -d 'Title' -r
