function __wt_cmux_setup --description "Set up cmux workspace layout: lazygit (right) + terminal (bottom-left)"
  command -q cmux; or return 0

  set -l force false
  set -l cli "claude --dangerously-skip-permissions"
  set -l prompt ""

  argparse 'force' 'cli=' 'prompt=' -- $argv 2>/dev/null

  set -q _flag_force; and set force true
  set -q _flag_cli; and set cli $_flag_cli
  set -q _flag_prompt; and set prompt $_flag_prompt

  # Resolve workspace ID
  set -l ws_id
  if test -n "$CMUX_WORKSPACE_ID"
    set ws_id "$CMUX_WORKSPACE_ID"
  else
    set ws_id (cmux identify --json 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin)['caller']['workspace_ref'])" 2>/dev/null)
  end
  if test -z "$ws_id"
    echo "cmux: not in a workspace — skipping layout setup"
    return 1
  end

  set -l workdir (pwd)

  # Get current pane topology
  set -l main_pane (cmux list-panes --workspace "$ws_id" 2>/dev/null | grep -oE 'pane:[0-9]+' | head -1)
  if test -z "$main_pane"
    echo "cmux: could not detect panes"
    return 1
  end

  # Idempotency guard — skip if layout already has multiple panes
  set -l pane_count (cmux list-panes --workspace "$ws_id" 2>/dev/null | grep -cE 'pane:[0-9]+')
  if test "$pane_count" -gt 1; and test "$force" = false
    return 0
  end

  set -l main_surface (cmux list-pane-surfaces --workspace "$ws_id" --pane "$main_pane" 2>/dev/null | grep -oE 'surface:[0-9]+' | head -1)
  if test -z "$main_surface"
    echo "cmux: could not detect main surface"
    return 1
  end

  # ── 1. Right split → lazygit (full height, narrow) ──────────────────────
  set -l lg_surface (cmux new-split right --workspace "$ws_id" 2>/dev/null | grep -oE 'surface:[0-9]+' | head -1)
  if test -n "$lg_surface"
    # Push main pane wider → lazygit gets ~30% width
    cmux resize-pane --workspace "$ws_id" --pane "$main_pane" -R --amount 200 2>/dev/null
    cmux send --workspace "$ws_id" --surface "$lg_surface" "cd '$workdir' && lazygit\n" 2>/dev/null
    cmux rename-tab --workspace "$ws_id" --surface "$lg_surface" "Git" 2>/dev/null
  end

  # ── 2. Bottom split under main → terminal ────────────────────────────────
  set -l term_surface (cmux new-split down --workspace "$ws_id" --surface "$main_surface" 2>/dev/null | grep -oE 'surface:[0-9]+' | head -1)
  if test -n "$term_surface"
    # Shrink terminal to ~20% height
    cmux resize-pane --workspace "$ws_id" --pane "$main_pane" -D --amount 500 2>/dev/null
    cmux send --workspace "$ws_id" --surface "$term_surface" "cd '$workdir'\n" 2>/dev/null
    cmux rename-tab --workspace "$ws_id" --surface "$term_surface" "Terminal" 2>/dev/null
  end

  # ── 3. Start Claude in main pane ─────────────────────────────────────────
  cmux focus-pane --pane "$main_pane" --workspace "$ws_id" 2>/dev/null
  if test -n "$prompt"
    cmux send --workspace "$ws_id" --surface "$main_surface" "$cli '$prompt'\n" 2>/dev/null
  else
    cmux send --workspace "$ws_id" --surface "$main_surface" "$cli\n" 2>/dev/null
  end
end
