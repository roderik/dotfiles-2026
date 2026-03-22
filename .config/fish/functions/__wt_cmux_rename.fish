function __wt_cmux_rename --description "Rename cmux workspace if cmux is available"
  set -l name $argv[1]
  test -z "$name"; and return
  command -q cmux; or return
  test -n "$CMUX_WORKSPACE_ID"; or return
  cmux workspace-action --action rename --title "$name" 2>/dev/null
end
