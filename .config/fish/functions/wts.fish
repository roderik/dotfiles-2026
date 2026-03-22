function wts --description "Set up or repair cmux workspace layout (lazygit + terminal pane)"
  if contains -- --force $argv
    __wt_cmux_setup --force
  else
    set -l pane_count (cmux list-panes 2>/dev/null | grep -cE 'pane:[0-9]+')
    if test "$pane_count" -gt 1
      echo "Workspace already has $pane_count panes. Use wts --force to rebuild."
      return 0
    end
    __wt_cmux_setup
  end
end
