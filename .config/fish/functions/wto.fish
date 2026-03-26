function wto --description "Launch Claude Code orchestrator in the main DALP repo"
  set -l main_repo ~/Development/dalp
  if not test -d "$main_repo/.git"
    echo "Error: main DALP repo not found at $main_repo"
    return 1
  end

  command -q cmux; or begin
    echo "Error: cmux is required for the orchestrator"
    return 1
  end

  # Rename and pin the current workspace
  cmux workspace-action --action rename --title "Orchestrator" 2>/dev/null
  cmux workspace-action --action pin 2>/dev/null
  cmux workspace-action --action move-top 2>/dev/null

  cd $main_repo
  echo "Orchestrator workspace ready at $main_repo"
end
