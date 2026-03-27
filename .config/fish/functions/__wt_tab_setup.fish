function __wt_tab_setup --description "Open a new workspace tab scoped to a directory — auto-detects zellij/cmux/bare"
    set -l cli "claude --dangerously-skip-permissions"
    set -l prompt ""
    set -l tab_name ""
    set -l workdir (pwd)
    set -l codex false

    argparse 'x' 'prompt=' 'name=' 'dir=' -- $argv 2>/dev/null

    if set -q _flag_x
        set cli "codex --full-auto"
        set codex true
    end
    set -q _flag_prompt; and set prompt $_flag_prompt
    set -q _flag_name; and set tab_name $_flag_name
    set -q _flag_dir; and set workdir $_flag_dir

    # Build the command to type into the main pane
    set -l launch_cmd
    if test -n "$prompt"
        set launch_cmd "$cli '$prompt'"
    else
        set launch_cmd "$cli"
    end

    # ── Zellij ───────────────────────────────────────────────────────────
    if test -n "$ZELLIJ"
        zellij action new-tab --layout wt --cwd "$workdir" 2>/dev/null
        sleep 0.5

        if test -n "$tab_name"
            zellij action rename-tab "$tab_name" 2>/dev/null
        end

        zellij action write-chars "$launch_cmd"
        zellij action write 10

        # Codex needs the prompt sent separately after startup
        if test "$codex" = true; and test -n "$prompt"
            sleep 3
            zellij action write-chars "$prompt"
            zellij action write 10
        end
        return 0
    end

    # ── Cmux ─────────────────────────────────────────────────────────────
    if command -q cmux
        set -l ws_name (test -n "$tab_name"; and echo "$tab_name"; or echo "worktree")

        # Create a NEW workspace (don't remodel the calling one)
        set -l new_ws (cmux new-workspace --name "$ws_name" --cwd "$workdir" 2>/dev/null)
        set -l ws_id (echo $new_ws | grep -oE 'workspace:[0-9]+' | head -1)

        if test -z "$ws_id"
            # Fallback: resolve current workspace
            if set -q CMUX_WORKSPACE_ID
                set ws_id "$CMUX_WORKSPACE_ID"
            else
                set ws_id (cmux identify --json 2>/dev/null | jq -r '.caller.workspace_ref' 2>/dev/null)
            end
        end

        if test -z "$ws_id"
            echo "cmux: could not create or resolve workspace"
            return 1
        end

        # Get main pane/surface
        set -l main_pane (cmux list-panes --workspace "$ws_id" 2>/dev/null | grep -oE 'pane:[0-9]+' | head -1)
        set -l main_surface (cmux list-pane-surfaces --workspace "$ws_id" --pane "$main_pane" 2>/dev/null | grep -oE 'surface:[0-9]+' | head -1)

        if test -z "$main_surface"
            echo "cmux: could not detect panes"
            return 1
        end

        # Right split → lazygit
        set -l lg_surface (cmux new-split right --workspace "$ws_id" 2>/dev/null | grep -oE 'surface:[0-9]+' | head -1)
        if test -n "$lg_surface"
            cmux resize-pane --workspace "$ws_id" --pane "$main_pane" -R --amount 200 2>/dev/null
            cmux send --workspace "$ws_id" --surface "$lg_surface" "cd '$workdir' && lazygit\n" 2>/dev/null
            cmux rename-tab --workspace "$ws_id" --surface "$lg_surface" "Git" 2>/dev/null
        end

        # Bottom split under main → terminal
        set -l term_surface (cmux new-split down --workspace "$ws_id" --surface "$main_surface" 2>/dev/null | grep -oE 'surface:[0-9]+' | head -1)
        if test -n "$term_surface"
            cmux resize-pane --workspace "$ws_id" --pane "$main_pane" -D --amount 500 2>/dev/null
            cmux send --workspace "$ws_id" --surface "$term_surface" "cd '$workdir'\n" 2>/dev/null
            cmux rename-tab --workspace "$ws_id" --surface "$term_surface" "Terminal" 2>/dev/null
        end

        # Launch CLI in main pane
        cmux focus-pane --pane "$main_pane" --workspace "$ws_id" 2>/dev/null
        cmux send --workspace "$ws_id" --surface "$main_surface" "$launch_cmd\n" 2>/dev/null

        # Codex needs the prompt sent separately after startup
        if test "$codex" = true; and test -n "$prompt"
            sleep 3
            cmux send --workspace "$ws_id" --surface "$main_surface" "$prompt\n" 2>/dev/null
        end
        return 0
    end

    # ── Bare terminal ────────────────────────────────────────────────────
    cd "$workdir"
    echo "Launching: $launch_cmd"
    eval $launch_cmd
end
