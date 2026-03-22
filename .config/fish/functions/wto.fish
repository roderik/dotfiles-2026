function wto --description "Launch orchestrator: Claude Code agent via ACP with Telegram control"
  # Always launch from the main DALP repo, not a worktree
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

  # Launch Claude Code via ACP from main repo
  echo "Launching Claude Code orchestrator via ACP..."
  echo "You can control this session from Telegram with:"
  echo "  /acp steer 'list all workspaces'"
  echo "  /acp steer 'status report'"
  echo "  /acp steer 'spawn workspace for PRD-xxx'"
  echo ""
  acpx claude --cwd "$main_repo" --label "orchestrator" \
    "You are the DALP orchestrator agent. Your job is to manage parallel Claude Code workspaces via cmux. You have these capabilities: list workspaces (cmux list-workspaces), create workspace (cmux new-workspace --cwd <dir>), send commands (cmux send --workspace <ws> --surface <surf> 'command'), rename workspace (cmux rename-workspace --workspace <ws> 'name'), close workspace (cmux close-workspace --workspace <ws>). You can spawn new agent workspaces with the wtn/wtc fish functions. You are connected to Telegram for remote control. When you receive Telegram messages, interpret them as commands: 'status' = list all workspaces and their state, 'new <ticket>' = spawn a new workspace for a Linear ticket (wtn <ticket>), 'check <workspace>' = read recent output from a workspace, 'stop <workspace>' = close a workspace. Stay running and responsive. Report workspace status when asked."
end
